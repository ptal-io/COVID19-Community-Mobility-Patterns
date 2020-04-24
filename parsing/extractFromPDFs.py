from collections import defaultdict
import glob
import os
import sys
import logging

import numpy as np
import pandas as pd
from tqdm.auto import tqdm
from geoIds import GEO_IDS
import json

# PyMuPDF
import fitz

def parse_stream(stream):
    data_raw = []
    data_transformed = []
    rotparams = None
    npatches = 0
    for line in stream.splitlines():
        if line.endswith(" cm"):
            # page 146 of https://www.adobe.com/content/dam/acom/en/devnet/pdf/pdfs/pdf_reference_archives/PDFReference.pdf
            rotparams = list(map(float, line.split()[:-1]))
        elif line.endswith(" l"):
            x,y = list(map(float, line.split()[:2]))
            a,b,c,d,e,f = rotparams
            xp = a*x+c*y+e
            yp = b*x+d*y+f
            data_transformed.append([xp,yp])
            data_raw.append([x,y])
        elif line.endswith(" m"):
            npatches += 1
        else:
            pass
    data_raw = np.array(data_raw)
    basex, basey = data_raw[-1]
    good = False
    if basex == 0.:
        data_raw[:,1] = basey - data_raw[:,1]
        data_raw[:,1] *= 100/60.
        data_raw = data_raw[data_raw[:,1]!=0.]
        if npatches == 1: good = True
    return dict(data=np.array(data_raw), npatches=npatches, good=good)

def parse_page(doc, ipage, verbose=False):
    categories = [
        "Retail & recreation",
        "Grocery & pharmacy",
        "Parks",
        "Transit stations",
        "Workplace",
        "Residential",
    ]

    counties = []
    curr_county = None
    curr_category = None
    data = defaultdict(lambda: defaultdict(list))
    pagetext = doc.getPageText(ipage)
    lines = pagetext.splitlines()
    tickdates = list(filter(lambda x:len(x.split())==3, set(lines[-10:])))
    for line in lines:
        # don't need these lines at all
        if ("* Not enough data") in line: continue
        if ("needs a significant volume of data") in line: continue
        
        # if we encountered a category, add to dict, otherwise
        # push all seen lines into the existing dict entry
        if any(line.startswith(c) for c in categories):
            curr_category = line
        elif curr_category:
            data[curr_county][curr_category].append(line)
            
        # If it doesn't match anything, then it's a county name
        if (all(c not in line for c in categories)
            and ("compared to baseline" not in line)
            and ("Not enough data" not in line)
            and ('Mobility trends ' not in line)
           ):
            # saw both counties already
            if len(data.keys()) == 2: break
            counties.append(line)
            curr_county = line

    newdata = {}
    for county in data:
        newdata[county] = {}
        for category in data[county]:
            # if the category text ends with a space, then there was a star/asterisk there
            # indicating lack of data. we skip these.
            if category.endswith(" "): continue
            temp = [x for x in data[county][category] if "compared to baseline" in x]
            if not temp: continue
            percent = int(temp[0].split()[0].replace("%",""))
            newdata[county][category.strip()] = percent
    data = newdata

    tomatch = []
    for county in counties:
        for category in categories:
            if category in data[county]:
                tomatch.append([county,category,data[county][category]])
    if verbose:
        logging.debug(len(tomatch))
        logging.debug(data)
    
    goodplots = []
    xrefs = sorted(doc.getPageXObjectList(ipage), key=lambda x:int(x[1].replace("X","")))
    for _, xref in enumerate(xrefs):
        stream = doc.xrefStream(xref[0]).decode()
        info = parse_stream(stream)
        if not info["good"]: continue
        goodplots.append(info)
    if verbose:
        logging.debug(len(goodplots))
    
    ret = []
    
    if len(tomatch) != len(goodplots):
        return ret
    
    
    for m,g in zip(tomatch,goodplots):
        xs = g["data"][:,0]
        ys = g["data"][:,1]
        maxys = ys[np.where(xs==xs.max())[0]]
        maxy = maxys[np.argmax(np.abs(maxys))]
        
        
        # parsed the tick date labels as text. find the min/max (first/last)
        # and make evenly spaced dates, one per day, to assign to x values between
        # 0 and 200 (the width of the plots).
        ts = list(map(lambda x: pd.Timestamp(x.split(None,1)[-1] + ", 2020"), tickdates))
        low, high = min(ts), max(ts)
        dr = list(map(lambda x:str(x).split()[0], pd.date_range(low, high, freq="D")))
        lutpairs = list(zip(np.linspace(0,200,len(dr)),dr))

        dates = []
        values = []
        asort = xs.argsort()
        xs = xs[asort]
        ys = ys[asort]
        for x,y in zip(xs,ys):
            date = min(lutpairs, key=lambda v:abs(v[0]-x))[1]
            dates.append(date)
            values.append(round(y,3))

        ret.append(dict(
            county=m[0],category=m[1],change=m[2],
            values=values,
            dates=dates,
            changecalc=maxy,
        ))
    return ret

def parse_page_total(doc, ipage, verbose=False):
    """
    First two pages
    """
    categories = [
        "Retail & recreation",
        "Grocery & pharmacy",
        "Parks",
        "Transit stations",
        "Workplaces",  # note the s at the end
        "Residential",
    ]

    curr_category = None
    data = defaultdict(lambda: defaultdict(list))
    pagetext = doc.getPageText(ipage)
    lines = pagetext.splitlines()
    # tickdates = list(filter(lambda x:len(x.split())==3, set(lines[-10:])))
    tickdates = []
    for line in lines:
        # don't need these lines at all
        if ("* Not enough data") in line: continue
        if ("needs a significant volume of data") in line: continue
        if 'Mobility trends ' in line or 'hubs' in line: continue
        # if pred_is_county_name and 
        
        # if we encountered a category, add to dict, otherwise
        # push all seen lines into the existing dict entry
        if any(line.startswith(c) for c in categories):
            curr_category = line
        elif line[:3] in ('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'):
            tickdates.append(line)
        elif line[0] not in ('+', '-'):
            continue
        elif curr_category:
            data[curr_category] = data.get(curr_category, []) + [line]

    newdata = {}
    for category in data:
        # if the category text ends with a space, then there was a star/asterisk there
        # indicating lack of data. we skip these.
        if category.endswith(" "): continue
        temp = data[category][0]
        percent = int(temp.split()[0].replace("%",""))
        newdata[category.strip()] = percent
    data = newdata

    tomatch = []
    for category in categories:
        if category in data:
            tomatch.append([category,data[category]])
    if verbose:
        logging.debug(len(tomatch))
        logging.debug(data)
    
    goodplots = []
    xrefs = sorted(doc.getPageXObjectList(ipage), key=lambda x:int(x[1].replace("X","")))
    for _, xref in enumerate(xrefs):
        stream = doc.xrefStream(xref[0]).decode()
        info = parse_stream(stream)
        if not info["good"]:
            logging.warning('Bad info, skipping') 
            continue
        goodplots.append(info)
    if verbose:
        logging.debug(len(goodplots))
    
    ret = []
    
    if len(tomatch) != len(goodplots):
        return ret
    
    for m,g in zip(tomatch,goodplots):
        xs = g["data"][:,0]
        ys = g["data"][:,1]
        maxys = ys[np.where(xs==xs.max())[0]]
        maxy = maxys[np.argmax(np.abs(maxys))]
        
        
        # parsed the tick date labels as text. find the min/max (first/last)
        # and make evenly spaced dates, one per day, to assign to x values between
        # 0 and 200 (the width of the plots).
        ts = list(map(lambda x: pd.Timestamp(x.split(None,1)[-1] + ", 2020"), tickdates))
        low, high = min(ts), max(ts)
        dr = list(map(lambda x:str(x).split()[0], pd.date_range(low, high, freq="D")))
        lutpairs = list(zip(np.linspace(0,200,len(dr)),dr))

        dates = []
        values = []
        asort = xs.argsort()
        xs = xs[asort]
        ys = ys[asort]
        for x,y in zip(xs,ys):
            date = min(lutpairs, key=lambda v:abs(v[0]-x))[1]
            dates.append(date)
            values.append(round(y,3))

        ret.append(dict(
            category=m[0],change=m[1],
            values=values,
            dates=dates,
            changecalc=maxy,
        ))
    return ret

def build_pdf_path(state, us, date):
    if us: 
        return f"us_pdfs/{date}/{date}_US_{state}_Mobility_Report_en.pdf"
    else:
        return f"pdfs/{date}/{date}_{state}_Mobility_Report_en.pdf"

def parse_state(state, us, date):
    pdfpath = build_pdf_path(state, us, date)
    logging.info(f"Parsing pages 2+ for state {state} : ", pdfpath)
    doc = fitz.Document(pdfpath)
    data = []
    for i in range(2, doc.pageCount-1):
        for entry in parse_page(doc, i):
            entry["state"] = state
            entry["page"] = i
            data.append(entry)
    df = pd.DataFrame(data)
    try:
        ncounties = df['county'].nunique()
    except KeyError:
        ncounties = 0
    logging.info(f"Parsed {len(df)} plots for {ncounties} counties in {state}")
    # try:
    #     return df[["state","county","category","change","changecalc","dates", "values","page"]]
    # except KeyError:
    #     # in this case, df is empty
    #     return df[["state", "category", "change", "changecalc", "dates", "values", "page"]]
    return df

def parse_state_total(state, us, date):
    """
    First two pages
    """
    pdfpath = build_pdf_path(state, us, date)
    logging.info(f"Parsing two first pages of state {state}: ", pdfpath)
    doc = fitz.Document(pdfpath)
    data = []
    for i in range(2):
        for entry in parse_page_total(doc, i):
            entry['state'] = state
            entry['page'] = i
            entry['county'] = 'total'
            data.append(entry)
    df = pd.DataFrame(data)
    return df

def parse_all(date, us=False):
    print("Parse All")
    pdfglob = glob.glob(f"us_pdfs/{date}/*.pdf") if us else glob.glob(f"pdfs/{date}/*.pdf")
    if us:
        states = [x.split("_US_",1)[1].split("_Mobility",1)[0] for x in pdfglob]
    else:
        states = [x.split("_")[1] for x in pdfglob]
    dfs = []
    for state in tqdm(states):
        try:
            state_counties = parse_state(state, us=us, date=date)
        except (KeyError, IndexError) as e:
            logging.warning(str(e))
            state_counties = pd.DataFrame()

        state = parse_state_total(state, us=us, date=date)
        dfs += [state, state_counties]
    df = pd.concat(dfs).reset_index(drop=True)
    data = []
    for _, row in tqdm(df.iterrows(), total=df.shape[0]):
        # do a little clean up and unstack the dates/values as separate rows
        dorig = dict()
        dorig["state"] = row["state"].replace("_"," ")
        dorig["county"] = row["county"]
        dorig["category"] = row["category"].replace(" & ","/").replace(" ","_").lower()
        dorig["page"] = row["page"]
        dorig["change"] = row["change"]
        dorig["changecalc"] = row["changecalc"]
        for x,y in zip(row["dates"], row["values"]):
            d = dorig.copy()
            d["date"] = x
            d["value"] = y
            data.append(d)
    df = pd.DataFrame(data)
    df = (df.assign(value=lambda f: f['value'] * (f['change'] / f['changecalc']))
          .replace("workplaces", 'workplace')
          .drop('changecalc', axis=1))

    if not us:
        df = (df.rename({'state': 'country_geoid', 
                         'county': 'region'}, axis=1)
              .assign(country=lambda f: f['country_geoid'].map(GEO_IDS)))
    return df


if __name__ == "__main__":
    dates = ['2020-04-11']
    us = len(sys.argv) > 1 and sys.argv[1].lower() == 'us'
    for date in dates:
        filename = f'{date}_us' if us else f'{date}_world'
        logging.info('Parsing date %s, storing in %s', date, filename)
        df = parse_all(date, us=us)
        df.to_csv(r'../data/googlemobiltytrends.csv')
        #df.to_json(f'data/{filename}.json', orient='records', indent=2)
        #df.to_csv(f'data/{filename}.csv', index=False)
