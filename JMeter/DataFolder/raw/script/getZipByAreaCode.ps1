﻿param (
	[string]$areCodeSet
)

function GetPrefixes($responseObj) {
	$tableWidth = 540
	$tableNode = 	$responseObj.parsedHtml.body.getElementsByTagName("table") | 
		Where-Object {$_.getAttribute("width", 0) -eq $tableWidth} |
		Select -first 1 
	
	if ($tableNode.count -eq 0) {
		return @()
	}

		
	$trNodes = $tableNode.getElementsByTagName("tr")		
	
	$fieldNames = @()
	$local:recCounter2 =0
	
	foreach($trNode in $trNodes) {
	
		if ($fieldNames.length -eq 0) {
			$trNode.getElementsByTagName("td") | ForEach-Object { $fieldNames += ($_.innerText -replace "\W")}
		}
		else {
			$obj = New-Object psobject
			$j=0
			$local:tdNodes = $trNode.getElementsByTagName("td")
			$tdNodes | ForEach-Object {
				$tdNode = $_
				if ($fieldNames.length -gt $j) {
					$fieldName = $fieldNames[$j++]
					Add-Member -InputObject $obj -MemberType NoteProperty -Name $fieldName -Value ($tdNode.innerText -replace "[`r`n]", "")
				}
			}	
			
			if ($recCounter2++ % 1 -eq 0) {
				Write-Host "  B. " $recCounter2 $obj
			}

			$obj
		}
	}
}



###################################################################
# Purpose: 
#    Issue WebRequest to URL a limited number (e.g. 5) times until 
#    any of the following conditions occur:
#        response body contains a success matching pattern
#        response body contains a failed matching pattern
#        maximum number of requests is reached
#
# Return:
#    Response object when $matchPattern or $exitPatter are true
#    otherwise, $null is returned
#
# param : 
#    $url - target website to for GET request 
#
#    $matchRegExPattern - regular expression pattern comparing body that
#                    denotes successful request
#
#    $exitRegExPattern - regular expression pattern comparing body that
#                   denotes failure and that no further request 
#                   attempts should be made
#    
function GetWebResponse([string] $url,
                        [string] $matchRegExPattern = $null, 
						[string] $exitRegExPattern  = $null) {

	[int]$local:maxRetry =5
	[int]$local:retryCount=0
	
	$local:responseObj = $null
	$local:isMatch = $false
	$local:isExitMatch = $false

	$error.Clear()

	try {
		do {
			$responseObj = Invoke-WebRequest -Uri $url
			$isMatch = $matchRegExPattern -eq $null -or $responseObj.Content -match "(?ism)$matchRegExPattern"
			$isExitMatch = $exitRegExPattern -ne $null -and $responseObj.Content -match "(?ism)$exitRegExPattern"
			
		} while ($retryCount++ -lt $maxRetry     `
		    -and $responseObj.statusCode -ne 200 `
			-and !$isMatch -and !$isExitMatch    )

		if ($retryCount -ge $maxRetry) {
			$responseObj=$null
		}
	}
	catch  {
		write-host "Error $url`t" + $error -foregroundcolor red -backgroundcolor yellow
		$responseObj = $null
		$error.Clear()
	}
	
	return $responseObj
}

$areaCodeSets = @((201,202,203,204,205,206,207,208,209,210,212,213,214,215,216,217,218,219,224,225,228,229,231,234,239,240,248,250,251,252,253,254,256,260,262,267,269,270,276,281,289),
			(301,302,303,304,305,306,307,308,309,310,312,313,314,315,316,317,318,319,320,321,323,325,330,331,334,336,337,339,340,347,351,352,360,361,385,386),
			(401,402,403,404,405,406,407,408,409,410,412,413,414,415,416,417,418,419,423,424,425,430,432,434,435,440,442,443,450,458,469,470,475,478,479,480,484),
			(501,502,503,504,505,506,507,508,509,510,512,513,514,515,516,517,518,519,520,530,539,540,541,551,559,561,562,563,567,570,571,573,574,575,580,585,586),
			(601,602,603,604,605,606,607,608,609,610,612,613,614,615,616,617,618,619,620,623,626,630,631,636,641,646,647,650,651,657,660,661,662,671,678,681,682,684),
			(701,702,703,704,705,706,707,708,709,712,713,714,715,716,717,718,719,720,724,727,731,732,734,740,747,754,757,760,762,763,765,769,770,772,773,774,775,778,779,780,781,785,786,787),
			(801,802,803,804,805,806,807,808,810,812,813,814,815,816,817,818,819,828,830,831,832,843,845,847,848,850,856,857,858,859,860,862,863,864,865,867,867,867,870,872,878),
			(901,902,902,903,904,905,906,907,908,909,910,912,913,914,915,916,917,918,919,920,925,928,929,931,936,937,938,939,940,941,947,949,951,952,954,956,970,971,972,973,978,979,980,985,989) )

if (!($areCodeSet -match "^[2-9]$")) {
	write-host "Error need areacode sequence 2-9"
}
else {

	$areaCodes = $areaCodeSets[$areCodeSet-2]

	$areaCodes | ForEach-Object {
		Write-Host $_
		$url = "http://www.getzips.com/cgi-bin/ziplook.exe?What=4&Area=$_"
		$responseObj = GetWebResponse $url "CITY AND STATE"
		GetPrefixes $responseObj
		
	} | ConvertTo-Csv -delimiter "`t" -notypeinformation  > "areaCodeToZip$($areCodeSet)00s.csv"

}