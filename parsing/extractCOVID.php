<?php

	$cntrycodes = json_decode(file_get_contents("countrycodes.json"));

	function getcode($cntry) {
		global $cntrycodes;
		foreach($cntrycodes as $k=>$v) {
			if ($v == $cntry)
				return $k;
		}
	}

	$countries = array();

	$file = fopen("../externalData/owid-covid-data.csv","r");
	$fileo = fopen('../internalData/COVIDcases.csv', 'w');

	fwrite($fileo, "country,cases,deaths\n");

	$cnt = 0;
	while(!feof($file)) {
		$l = explode(",",fgets($file));
		if ($cnt > 0) {
			
			$cntry = getcode($l[0]);
			$date = $l[2];
			if ($date == "2020-04-11") {
				fwrite($fileo, $cntry . "," . $l[3] . "," . $l[5] . "\n");
			}

		}
		$cnt++;
		
	}
	fclose($fileo);

	fclose($file);

?>