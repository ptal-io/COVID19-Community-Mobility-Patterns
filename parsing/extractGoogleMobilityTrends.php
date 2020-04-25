<?php
	/*******************************
	@author Grant McKenzie
	@date April 2020
	@desc Convert CSV file containing google data to individual files split by country and category.
	********************************/

	$dates = array("2020-02-15","2020-02-16","2020-02-17","2020-02-18","2020-02-19","2020-02-20","2020-02-21","2020-02-22","2020-02-23","2020-02-24","2020-02-25","2020-02-26","2020-02-27","2020-02-28","2020-02-29","2020-03-01","2020-03-02","2020-03-03","2020-03-04","2020-03-05","2020-03-06","2020-03-07","2020-03-08","2020-03-09","2020-03-10","2020-03-11","2020-03-12","2020-03-13","2020-03-14","2020-03-15","2020-03-16","2020-03-17","2020-03-18","2020-03-19","2020-03-20","2020-03-21","2020-03-22","2020-03-23","2020-03-24","2020-03-25","2020-03-26","2020-03-27","2020-03-28","2020-03-29","2020-03-30","2020-03-31","2020-04-01","2020-04-02","2020-04-03","2020-04-04","2020-04-05","2020-04-06","2020-04-07","2020-04-08","2020-04-09","2020-04-10","2020-04-11");


	$ccats = array("Retail & recreation", "Grocery & pharmacy", "Parks", "Transit stations", "Workplace", "Residential");

	$countries = (Object)array();

	$file = fopen("../externalData/Global_Mobility_Report.csv","r");
	$cnt = 0;
	while(! feof($file)) {
		$l = explode(",",fgets($file));
		if ($cnt > 0 & isset($l[2]) && strlen($l[3]) == 0) {

			$cntry = $l[0];
			$region = $l[2];
			if (strlen($region) == 0)
				$region = $cntry;

			//$cat = preg_replace("/[^A-Za-z0-9]/", '', $l[1]);
			$date = trim($l[4]);
			//$val = $l[7];
			if (!isset($countries->$cntry))
				$countries->$cntry = (Object)array();

			if (!isset($countries->$cntry->$region))
				$countries->$cntry->$region = (Object)array();

			if (strlen($l[4]) > 0) {
				for($i=5;$i<11;$i++) {
					$c = $ccats[($i-5)];
					if(!isset($countries->$cntry->$region->$c))
						$countries->$cntry->$region->$c = array();
					
					//echo $c . "\t" . intval(trim($l[$i]));
					$countries->$cntry->$region->$c[$date] = intval(trim($l[$i]));
				}
			}
		}
		$cnt++;
		/*if ($cnt > 2)
			break; */
		
	}
	fclose($file);


	//var_dump($countries->AE->AE);
	
	foreach($countries as $cntry=>$provs) {
		foreach($provs as $prov=>$cats) {
			foreach($cats as $cat=>$cdates) {
				$udates = array();
				foreach($dates as $date) {
					if (!isset($countries->$cntry->$prov->$cat[$date])) {
					 	$udates[$date] =  "NA";
					} else {
						$udates[$date] = $countries->$cntry->$prov->$cat[$date];
					}
				}
				ksort($udates);
				$countries->$cntry->$prov->$cat = $udates;
			}
		}
	}

	
	foreach($countries as $cntry=>$provs) {
		foreach($ccats as $cat) {
			$catout = preg_replace("/[^A-Za-z0-9]/", '', $cat);
			$afile = fopen("../externalData/MobilityByCountry/".$cntry."_".$catout.".csv","w");
			fwrite($afile, "date");
			foreach($provs as $prov=>$cats) {
				fwrite($afile, ",".$prov);
			}
			fwrite($afile, "\n");
			foreach($dates as $date) {
				fwrite($afile, $date);
				foreach($provs as $prov=>$cats) {
					if (isset($provs->$prov->$cat))
						fwrite($afile, ",".$provs->$prov->$cat[$date]);
					else
						fwrite($afile, ",NA");
				}
				fwrite($afile, "\n");
			}
			fclose($afile);
		}
	}
	

?>