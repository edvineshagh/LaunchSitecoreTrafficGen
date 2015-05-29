<#param (
	[string]$areCodeSet
)
#>
function GetPrefixes($responseObj) {
	$tableWidth = "530px"
	$tableNode = 	$responseObj.parsedHtml.body.getElementsByTagName("table") | 
		Where-Object {$_.getAttribute("style", 0).width -eq $tableWidth} |
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

$streetLetter = @("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9")


$streetLetter | ForEach-Object {
	Write-Host $_
	$url = "http://www.livingplaces.com/streets/$_.html"
	$responseObj = GetWebResponse $url "CITY AND STATE"
	GetPrefixes $responseObj
	
} | ConvertTo-Csv -delimiter "`t" -notypeinformation  > "..\..\Names\streetNames.csv"

