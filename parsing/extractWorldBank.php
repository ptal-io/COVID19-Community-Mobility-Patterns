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

	$file = fopen("../externalData/WorldBankIndicators.csv","r");

	$cnt = 0;
	while(!feof($file)) {
		$l = explode(",",fgets($file));
		if ($cnt > 0) {
			
			$cntry = getcode($l[0]);
			$indicator = $l[3];
			$type = $l[4];
			$val = strlen($l[16]) > 0 ? $l[16] : $l[15];
			$val = strlen($val) > 0 ? $val : $l[11];
			if (strlen($val) == 0)
				$val = "NA";

			if (!isset($countries[$indicator]) && strlen($indicator) > 5)
				$countries[$indicator] = array();

			if (strlen($cntry) > 0 && strlen($indicator) > 5)
				$countries[$indicator][$cntry] = trim($val);

		}
		$cnt++;
		
	}
	fclose($file);

	$indicators = array();
	foreach($countries as $indicator=>$cntries) {
			$indicators[] = $indicator;
	}
	$ucountries = array();
	foreach($countries as $indicator=>$cntries) {
		foreach($cntries as $cntry=>$val) {
			$ucountries[] = $cntry;
		}
	}
	$ucountries = array_unique($ucountries);
	asort($ucountries);

	$indicators = array_unique($indicators);
	asort($indicators);

	$file = fopen('../internalData/GCI4.csv', 'w');
	fwrite($file, "country,");
	for($i=0;$i<count($indicators);$i++) {
		fwrite($file, trim(str_replace('"','',$indicators[$i])) . ",");
	}
	fwrite($file, "\n");

	foreach($ucountries as $j) {
		fwrite($file, $j . ",");
		for($i=0;$i<count($indicators);$i++) {
			if (isset($countries[$indicators[$i]][$j]))
				fwrite($file, $countries[$indicators[$i]][$j] . ",");
			else
				fwrite($file, "NA,");
		}
		fwrite($file, "\n");
	}

	fclose($file);

?>