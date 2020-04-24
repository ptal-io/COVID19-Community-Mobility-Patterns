<?php
	/*******************************
	@author Grant McKenzie
	@date April 2020
	@desc Convert CSV file containing google data to individual files split by country and category.
	********************************/

	$dates = array("2020-02-29","2020-03-01","2020-03-02","2020-03-03","2020-03-04","2020-03-05","2020-03-06","2020-03-07","2020-03-08","2020-03-09","2020-03-10","2020-03-11","2020-03-12","2020-03-13","2020-03-14","2020-03-15","2020-03-16","2020-03-17","2020-03-18","2020-03-19","2020-03-20","2020-03-21","2020-03-22","2020-03-23","2020-03-24","2020-03-25","2020-03-26","2020-03-27","2020-03-28","2020-03-29","2020-03-30","2020-03-31","2020-04-01","2020-04-02","2020-04-03","2020-04-04","2020-04-05","2020-04-06","2020-04-07","2020-04-08","2020-04-09","2020-04-10","2020-04-11");

	$ccats = array("grocery/pharmacy","parks","residential","retail/recreation","transit_stations","workplace");

	$countries = (Object)array();

	$file = fopen("data/googlemobilitytrends.csv","r");
	while(! feof($file)) {
		$l = explode(",",fgets($file));

		$region = $l[3];
		$cntry = $l[6];
		$cat = preg_replace("/[^A-Za-z0-9]/", '', $l[1]);
		$date = $l[4];
		$val = $l[7];
		if (!isset($countries->$cntry))
			$countries->$cntry = (Object)array();

		if (!isset($countries->$cntry->$region))
			$countries->$cntry->$region = (Object)array();

		if (!isset($countries->$cntry->$region->$cat))
			$countries->$cntry->$region->$cat = array();

		//echo $cntry . "\t" . $region . "\t" . $cat . "\t" . $date . "\t" . $val . "\n";
		$countries->$cntry->$region->$cat[$date] = $val;
		
	}
	fclose($file);

	//var_dump($countries->CA);


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
			$cat = preg_replace("/[^A-Za-z0-9]/", '', $cat);
			$afile = fopen("data/MobilityByCountry/".$cntry."_".$cat.".csv","w");
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