<?php
	/*******************************
	@author Grant McKenzie
	@date April 2020
	@desc Convert CSV file containing google data to individual files split by country and category.
	********************************/

	$dates = array("2020-02-15","2020-02-16","2020-02-17","2020-02-18","2020-02-19","2020-02-20","2020-02-21","2020-02-22","2020-02-23","2020-02-24","2020-02-25","2020-02-26","2020-02-27","2020-02-28","2020-02-29","2020-03-01","2020-03-02","2020-03-03","2020-03-04","2020-03-05","2020-03-06","2020-03-07","2020-03-08","2020-03-09","2020-03-10","2020-03-11","2020-03-12","2020-03-13","2020-03-14","2020-03-15","2020-03-16","2020-03-17","2020-03-18","2020-03-19","2020-03-20","2020-03-21","2020-03-22","2020-03-23","2020-03-24","2020-03-25","2020-03-26","2020-03-27","2020-03-28","2020-03-29","2020-03-30","2020-03-31","2020-04-01","2020-04-02","2020-04-03","2020-04-04","2020-04-05","2020-04-06","2020-04-07","2020-04-08","2020-04-09","2020-04-10","2020-04-11","2020-04-12","2020-04-11");

	$cats = (Object)array();
	$cats->{"Retail & recreation"} = array();
	$cats->{"Grocery & pharmacy"} = array();
	$cats->{"Parks"} = array();
	$cats->{"Transit stations"} = array();
	$cats->{"Workplace"} = array();
	$cats->{"Residential"} = array();

	$catsa = array("Retail & recreation", "Grocery & pharmacy", "Parks", "Transit stations", "Workplace", "Residential");

	$countries = (Object)array();

	$file = fopen("../externalData/Global_Mobility_Report.csv","r");

	$cnt = 0;
	while(! feof($file)) {
		$l = explode(",",fgets($file));
		if ($cnt > 0 & isset($l[2]) && strlen($l[3]) == 0) {
			
			$cntry = $l[0];
			$region = strlen($l[2]) > 0 ? $l[2] : $cntry;
			/*$date = $l[4];
			$rr = $l[5];
			$gp = $l[6];
			$p = $l[7];
			$ts = $l[8];
			$w = $l[9];
			$r = $l[10]; */

			if (!isset($countries->$cntry))
				$countries->$cntry = (Object)array();

			if (!isset($countries->$cntry->$region))
				$countries->$cntry->$region = array();

			if (strlen($l[4]) > 0) {
				$item = (Object)array();
				$item->date = str_replace("-","",trim($l[4]));
				for($i=5;$i<11;$i++) {
					$c = $catsa[($i-5)];
					$item->$c = intval(trim($l[$i]));
				}
			}

			$countries->$cntry->$region[] = $item;

			
		}
		$cnt++;
	}
	fclose($file);


	$file = fopen("countries.json","w");
	fwrite($file, json_encode($countries));
	fclose($file);

?>