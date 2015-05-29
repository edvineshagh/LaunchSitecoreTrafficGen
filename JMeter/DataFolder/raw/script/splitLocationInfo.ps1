$states = @("AL","AK","AS","AZ","AR","CA","CO","CT","DE","FL","GA","GU","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","PR","RI","SC","SD","TN","TX","UT","VT","VI","VA","WA","WV","WI","WY")

$locations = Get-Content ..\locationInfo.csv | convertFrom-csv -delimiter "`t" 

$states | ForEach-Object {
	
	$state = $_
	$outCsvFile = "..\locationInfo-$state.csv"
	$locations | 
	Where-Object {$state -eq $_.CityAndState.Substring($_.CityAndState.length-2, 2).toupper()} |
	Where-Object {$_.latitude.length -gt 0 -and $_.longitude.length -gt 0} |
	ConvertTo-Csv -NoTypeInformation > $outCsvFile
	
}
