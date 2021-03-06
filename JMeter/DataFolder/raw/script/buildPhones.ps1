<#
http://stackoverflow.com/questions/7167604/how-accurately-should-i-store-latitude-and-longitude
Latitude/Longitude accuracy.  e.g. 37.4946568, -120.8465941 is Turlock, CA 95382.  So, Add 001 suffix
Test here: http://stevemorse.org/jcal/latlon.php
decimal  degrees    distance
places
-------------------------------  
0        1.0        111 km
1        0.1        11.1 km
2        0.01       1.11 km
3        0.001      111 m
4        0.0001     11.1 m
5        0.00001    1.11 m
6        0.000001   0.111 m
7        0.0000001  1.11 cm
8        0.00000001 1.11 mm

#>

function GetData {

    Param (
		[parameter(ValueFromPipeline=$true)]
        [int[]]$areaCodes
    )
	
    Begin {
        Write-Verbose "Initialize stuff in Begin block"
    }
    Process {
		$urlPrefix = "http://www.allareacodes.com/"
		$local:recCounter = 0
        ForEach ($areaCode in $areaCodes) {
			$local:areaCodeUrl = "$urlPrefix$areaCode"
			$local:responseObj = GetWebResponse $areaCodeUrl
			
			$headingText = GetHeadingText $responseObj
			$prefixes = GetPrefixes $responseObj "Area Code $areaCode Prefixes"
			$prefixes | Where-Object {$_.PrefixLink -ne $null} | ForEach-Object {
			
				$prefixRecord = $_
				
				Add-Member -InputObject $prefixRecord -MemberType NoteProperty -Name "GenState" -Value $null
				Add-Member -InputObject $prefixRecord -MemberType NoteProperty -Name "GenMajorCity" -Value $null
				Add-Member -InputObject $prefixRecord -MemberType NoteProperty -Name "GenTimezone" -Value $null
				
				$headingText | Where-Object { $_ -match "(State|Major City|Timezone):" } | ForEach {
					$local:arrRec = ($_ -split ":")
					$local:fieldName = "Gen" + ($arrRec[0] -replace "\W", "")
					$prefixRecord.$fieldName = ($arrRec[1] -replace "[`r`n]", "")
				}
				Write-Host "A1. " ($recCounter++) $prefixRecord
				
				$prefixRecord

			<#
				# Get Phone numbers
				$phoneListUrl = $urlPrefix + $prefixRecord.PrefixLink
				$responseObj = GetWebResponse( $phoneListUrl )

				Add-Member -InputObject $prefixRecord -MemberType NoteProperty -Name "IsBusiness" -Value $null
				Add-Member -InputObject $prefixRecord -MemberType NoteProperty -Name "Name" -Value $null
				Add-Member -InputObject $prefixRecord -MemberType NoteProperty -Name "TelephoneNumber" -Value $null
				Add-Member -InputObject $prefixRecord -MemberType NoteProperty -Name "City" -Value $null
				Add-Member -InputObject $prefixRecord -MemberType NoteProperty -Name "Address" -Value $null
				

				# Get Business Phone Numbers
				$busNums = GetPhoneNumbers $responseObj ("Business and Government " + $prefixRecord.Prefix + "XXXX Numbers").replace("(", "\(").replace(")","\)")
				
				$busNums | ForEach-Object {
					$local:telephone = $_.Telephone
					if ($telephone -eq $null) { $telephone = $_.TelephoneNumber}
					$prefixRecord.IsBusiness = $true
					$prefixRecord.TelephoneNumber = $telephone
					$prefixRecord.Name = $_.Name
					$prefixRecord.City = $_.City
					$prefixRecord.Address = $_.Address
					
					Write-Host "A1. " ($recCounter++) $prefixRecord
				
					$prefixRecord			
				
				}
				
				# Get Residential Phone Numbers
				$resNums = GetPhoneNumbers $responseObj ("Residential " + $_.Prefix + "XXXX Numbers").replace("(", "\(").replace(")","\)")

				$resNums | ForEach-Object {
					$local:telephone = $_.Telephone
					if ($telephone -eq $null) { $telephone = $_.TelephoneNumber}

					$prefixRecord.IsBusiness = $false
					$prefixRecord.TelephoneNumber = $telephone
					$prefixRecord.Name = $_.Name
					$prefixRecord.City = $_.City
					$prefixRecord.Address = $_.Address
					
					Write-Host "A2. " ($recCounter++) $prefixRecord
				
					$prefixRecord
				}	
				#>
			}           
        }
    }

    End {
        Write-Verbose "Final work in End block"
    }

}

function GetHeadingText($responseObj) {
	(($responseObj.parsedHtml.body.getElementsByClassName("box npa_details") | 
	 Select-Object -First 1).outerText -replace "`r","" ) -split "`n"
}

function GetPrefixes($responseObj, $headingMatch) {
	$h2Node = 	$responseObj.parsedHtml.body.getElementsByTagName("h2") | 
		Where-Object {$_.InnerText -match $headingMatch} |
		Select -first 1 
	
	if ($h2Node.count -eq 0) {
		return @()
	}
	
	$divNode = $h2Node.parentNode

		
	$trNodes = $divNode.getElementsByTagName("tr")		
	
	$fieldNames = @()
	$local:recCounter2 =0
	
	foreach($trNode in $trNodes) {
	
		if ($fieldNames.length -eq 0) {
			$trNode.getElementsByTagName("th") | ForEach-Object { $fieldNames += ($_.innerText -replace "\W")}
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
					$anchorNode = $tdNode.getElementsByTagName("a") | Select-Object -First 1
					
					if ($anchorNode -ne $null) {
						Add-Member -InputObject $obj -MemberType NoteProperty -Name ($fieldName + "Link") -Value $anchorNode.getAttribute("href")
					}
				}
			}	
			
			if ($recCounter2++ % 100 -eq 0) {
				Write-Host "  B. " $recCounter2 $obj
			}

			$obj
		}
	}
}


function GetPhoneNumbers($responseObj, $headingMatch) {

	$h2Node = 	$responseObj.parsedHtml.body.getElementsByTagName("h2") | 
		Where-Object {$_.InnerText -match $headingMatch} |
		Select -first 1 
	
	if ($h2Node.count -eq 0) {
		return @()
	}
	
	$divNode = $h2Node.parentNode
	
	$local:recCounter3=0
	
	$trNodes = @()
	do {
		do {
			$divNode = $divNode.nextSibling
		} while ($divNode -ne $null -and $divNode.nodeName -ne "div")

		if ($divNode -ne $null) {
			$trNodes += $divNode.getElementsByTagName("tr")
		}
	}
	while($divNode.getAttribute("class") -contains "col-md4")
	
	$fieldNames = @()

	foreach($trNode in $trNodes) {
	
		if ($fieldNames.length -eq 0) {
			$trNode.getElementsByTagName("th") | ForEach-Object { $fieldNames += ($_.innerText -replace "\W")}
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
					$anchorNode = $tdNode.getElementsByTagName("a") | Select-Object -First 1
					
					if ($anchorNode -ne $null) {
						Add-Member -InputObject $obj -MemberType NoteProperty -Name ($fieldName + "Link") -Value $anchorNode.getAttribute("href")
					}
				}
			}	
			if ($recCounter3++ % 100 -eq 0) {
				Write-Host "    C. " $recCounter3 $obj
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

$areaCode = 989
$areaCodes = (201,202,203,204,205,206,207,208,209,210,212,213,214,215,216,217,218,219,224,225,228,229,231,234,239,240,248,250,251,252,253,254,256,260,262,267,269,270,276,281,289,301,302,303,304,305,306,307,308,309,310,312,313,314,315,316,317,318,319,320,321,323,325,330,331,334,336,337,339,340,347,351,352,360,361,385,386,401,402,403,404,405,406,407,408,409,410,412,413,414,415,416,417,418,419,423,424,425,430,432,434,435,440,442,443,450,458,469,470,475,478,479,480,484,501,502,503,504,505,506,507,508,509,510,512,513,514,515,516,517,518,519,520,530,539,540,541,551,559,561,562,563,567,570,571,573,574,575,580,585,586,601,602,603,604,605,606,607,608,609,610,612,613,614,615,616,617,618,619,620,623,626,630,631,636,641,646,647,650,651,657,660,661,662,671,678,681,682,684,701,702,703,704,705,706,707,708,709,712,713,714,715,716,717,718,719,720,724,727,731,732,734,740,747,754,757,760,762,763,765,769,770,772,773,774,775,778,779,780,781,785,786,787,801,802,803,804,805,806,807,808,810,812,813,814,815,816,817,818,819,828,830,831,832,843,845,847,848,850,856,857,858,859,860,862,863,864,865,867,867,867,870,872,878,901,902,902,903,904,905,906,907,908,909,910,912,913,914,915,916,917,918,919,920,925,928,929,931,936,937,938,939,940,941,947,949,951,952,954,956,970,971,972,973,978,979,980,985,989)
#$responseObj = GetWebResponse "http://www.allareacodes.com/989" "Area Code 989 Details"
#GetHeadingFromHtml $responseObj.Content "<h2>Area Code $areaCode Details</h2>" @("State:", "Major City:", "Timezone:")
#GetRecordsFromHtml $responseObj.content "<h2>Area Code $areaCode Prefixes</h2>"
#GetPrefixes $responseObj "Area Code 989 Prefix"
#GetData $areaCode
$areaCodes | ForEach-Object{ GetData $_} |	Where-Object { $_ } | ConvertTo-Csv -delimiter "`t" -notypeinformation  > phoneNums2.csv