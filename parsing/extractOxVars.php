<?php

	$cntrycodes = json_decode(file_get_contents("countrycodes.json"));
	//var_dump($cntrycodes);

	function getcode($cntry) {
		global $cntrycodes;
		foreach($cntrycodes as $k=>$v) {
			if ($v == $cntry)
				return $k;
		}
	}


	$file = fopen("OxCGRT2.csv","r");
	$cnt = 0;
	while(! feof($file)) {
		if ($cnt > 0) {
			$l = explode(",",fgets($file));
			
			$cntry = getcode($l[1]);
			if (!file_exists("oxvars/".$cntry.".csv")) {
				$afile = fopen("oxvars/".$cntry.".csv","w");
				fwrite($afile, "Date,S1_Schoolclosing,S1_IsGeneral,S2_Workplaceclosing,S2_IsGeneral,S3_Cancelpublicevents,S3_IsGeneral,S4_Closepublictransport,S4_IsGeneral,S5_Publicinformationcampaigns,S5_IsGeneral,S6_Restrictionsoninternalmovement,S6_IsGeneral,S7_Internationaltravelcontrols,S8_Fiscalmeasures,S9_Monetarymeasures,S10_Emergencyinvestmentinhealthcare,S11_InvestmentinVaccines,S12_Testingframework,S13_Contacttracing,ConfirmedCases,ConfirmedDeaths,StringencyIndex,StringencyIndexForDisplay\n");
				fclose($afile);
			}

			$date = $l[2];

			//if ($cnt > 100)
			//	break;
			if ($date >= 20200229 and $date <= 20200411) {
				$afile = fopen("oxvars/".$cntry.".csv","a");
				$year = substr($date,0,4);
				$mo = substr($date,4,2);
				$day = substr($date,6,2);
				fwrite($afile, "\"".$year . "-" . $mo . "-".$day."\"");
				$g = "";
				for($i=3;$i<count($l);$i++) {
					$g .= ",".trim($l[$i]);
				}
				//fwrite($afile, "\n");
				$g = rtrim($g,",");
				fwrite($afile, $g."\n");
				fclose($afile);
			}
		}
		$cnt++;
	}
	fclose($file);

?>