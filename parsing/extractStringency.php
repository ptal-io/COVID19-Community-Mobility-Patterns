<?php

	$cntrycodes = json_decode(file_get_contents("countrycodes.json"));
	var_dump($cntrycodes);

	function getcode($cntry) {
		global $cntrycodes;
		foreach($cntrycodes as $k=>$v) {
			if ($v == $cntry)
				return $k;
		}
	}


	$file = fopen("OxCGRT.csv","r");
	//$cnt = 0;
	while(! feof($file)) {
		$l = explode(",",fgets($file));
		
		$cntry = getcode($l[1]);
		$date = $l[2];
		$cases = $l[22];
		$deaths = $l[23];
		$val = $l[24];
		
		//if ($cnt > 100)
		//	break;
		if ($date >= 20200229 and $date <= 20200411) {
			echo $cntry . "\t" . $date . "\t" . $val . "\n";
			$afile = fopen("ox/".$cntry.".csv","a");
			$year = substr($date,0,4);
			$mo = substr($date,4,2);
			$day = substr($date,6,2);
			fwrite($afile, $year . "-" . $mo . "-".$day.",".$val.",".$cases.",".$deaths . "\n");
			fclose($afile);
		}
		//$cnt++;
	}
	fclose($file);

?>