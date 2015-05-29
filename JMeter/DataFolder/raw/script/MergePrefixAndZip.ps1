$infoByCity = @{}

(Get-Content .\areaCodes.csv | ConvertFrom-Csv -delimiter "`t") | foreach {
	
	$local:key = $_.CityAndState
	
	if ($key.length -gt 0) {
	
		$key = $key.tolower()
	
		if (!$infoByCity.containsKey($key)) { 
			$infoByCity.Add($key, (,$_)) 
		}
		else {
			$i = $infoByCity.get_item($_) + $_
			$infoByCity.set_item($key, $i)
		}
		
	}
}

$sourceFile = Get-content .\phoneNums2.csv | ConvertFrom-CsV -delimiter "`t"
$recordCounter =0
$sourceFile | ForEach {
	
	$local:key = $_.PrimaryCity
	
	if ($key.length -gt 0 -and $infoByCity.containsKey($key.tolower())) {
	
	  $key = $key.tolower()
	  
	  $local:matchedCities = $infoByCity.get_item($key)
	  $local:cityCount = $matchedCities.count
	  $local:city = $null
	  $local:maxRetry =10
	  $areaCode = $_.Prefix.substring(1,3)
	  
	  while ($maxRetry-- -gt 0 -and ($city -eq $null -or $city.Area -ne $areaCode)) {
	  
	  	$cityIndex =0
	  	if ($cityCount -gt 1) {
	  		$cityIndex = Get-Random -minimum 0 -maximum ($cityCount-1)
		}
	  	$city = $matchedCities[$cityIndex]
	  } 
	  
	  if ($city -ne $null -and $city.Area -eq $areaCode) {
	  
	  	  #Write-Host (++$recordCounter) " zip:" $city.Zip
		  
		  $county = $_.County
		  if ($county.length -eq 0) {$county = $city.County}
		  
		  $obj = New-Object psobject
		  Add-Member -InputObject $obj -MemberType NoteProperty -Name "Prefix" -Value $_.Prefix
		  Add-Member -InputObject $obj -MemberType NoteProperty -Name "CityAndState" -Value $_.PrimaryCity
		  Add-Member -InputObject $obj -MemberType NoteProperty -Name "County" -Value $county
		  Add-Member -InputObject $obj -MemberType NoteProperty -Name "Usage" -Value $_.Usage
		  Add-Member -InputObject $obj -MemberType NoteProperty -Name "LongState" -Value $_.GenState
		  Add-Member -InputObject $obj -MemberType NoteProperty -Name "Zip" -Value $city.Zip
		  Add-Member -InputObject $obj -MemberType NoteProperty -Name "Timezone" -Value $_.GenTimezone
		  Add-Member -InputObject $obj -MemberType NoteProperty -Name "Latitude" -Value $city.Latitude
		  Add-Member -InputObject $obj -MemberType NoteProperty -Name "Longitude" -Value $city.Longitude
		  
		  $obj
	  }
	  else {
	  	 # Write "Skip" $_
	  }
	}
} | Where-object {$_} | ConvertTo-Csv -Delimiter "`t" -notypeinformation > locationInfo.csv