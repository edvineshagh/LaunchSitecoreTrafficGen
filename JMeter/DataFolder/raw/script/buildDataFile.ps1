# source: http://www.geonames.org/export/
<#
#Get-Content -totalcount 5 .\allCountries.txt
$regionCsvFile = "test.txt"
$zipcodeCsvFile= "usPostal\allCountries.txt"

# Readme for GeoNames Gazetteer extract files
$regionCsvHeaders = @("geonameid","name","asciiname","alternatenames","latitude","longitude","feature_class","feature_code","country_code","cc2","admin1_code","admin2_code","admin3_code","admin4_code","population","elevation","dem","timezone","modification_date")
$regionDisplayHeaders = @("geonameid","asciiname","latitude","longitude","country_code","admin1_code","population", "timezone") 

$zipCsvHeaders = @( 
	"country_code",
	"postal_code",
	"place_name",	# City (e.g. San Francisco)
	"admin_name1",	# state - long name (e.g. California)
	"admin_code1",	# state - short name (e.g. CA)
	"admin_name2",	# county/region name
	"admin_code2",	# county/region code
	"admin_name3",
	"admin_code3",
	"latitude",
	"longitude",
	"accuracy")
	
Import-Csv -Delimiter "`t"  -Header $zipCsvHeaders -path $zipcodeCsvFile `
	| where-object {$_.postal_code.length -ge 5} `
	| Where-object { $_.postal_code -match '^\d{5,}'} `
	| ForEach-Object { $_.postal_code -replace "-.*", ""}


#function CityCountryObj($inputObj
Import-Csv -Delimiter "`t"  -Header $regionCsvHeaders -path $regionCsvFile `
	| Where-Object {$_.population -gt 1000} `
	| Select-Object -property $regionDisplayHeaders 
#>
		

		
# The following file issues a request against 
# http://www.fonefinder.net/ to build a list of zip-to-area-code mapping
#
Function GenerateAreaCodeFile {

$inZipCodeFile = "zip.txt"
$outCsvFile = "test3.txt"

$pattern =">Zip Code(?!<TD)*[^>]+>(?'zipCode'.*?)<T.*?"`
         +">Area Code(?!<TD)*[^>]+>(?'areaCode'.*?)<T.*?"`
         +">Countyname(?!<TD)*[^>]+>(?'countyName'.*?)<T.*?"`
         +">State Name(?!<TD)*[^>]+>(?'stateName'.*?)<T.*?"`
         +">City(?!<TD)*[^>]+>(?'city'.*?)<T.*?"`
         +">Timezone(?!<TD)*[^>]+>(?'timezone'.*?)<T.*?"`
         +">Nearest City(?!<TD)*[^>]+>(?'nearCity'.*?)<T.*?"`
         +">Population(?!<TD)*[^>]+>(?'population'.*?)<T.*?"`
         +">Avg. House value(?!<TD)*[^>]+>(?'avgHouseVal'.*?)<T.*?"`
         +">Income per household(?!<TD)*[^>]+>(?'houseHoldIncome'.*?)<T.*"
		 

#Get-Content $inZipCodeFile -TotalCount 15 |

# find last line to skip
$skipLine=0
$lastProcessedZip=68695
foreach ($line in (Get-Content .\zip.txt)) {if ($line -eq $lastProcessedZip) {break;} else {$skipLine++}}

$requestProcessed =0
$maxRetryCount = 5
Get-Content $inZipCodeFile | select-object -skip $skipLine |
	ForEach-Object {
		$url = "http://www.fonefinder.net/findzip.php?zipcode=$_&zipquerytype=Search+by+Zip"
		$error.clear()
		$retryCounter = $maxRetryCount
		while( $retryCounter -gt 0 ) {
		
			if ($retryCounter-- -ne $maxRetryCount) {
				$sec = 500
				write-host "sleeping for $sec milliseconds"
				Start-Sleep -milliseconds $sec
			}
			
			write-host "Request: " ($requestProcessed++) " `tzip: $_"
		
			try {
				#$responseHtml = (New-Object System.Net.WebClient).DownloadString($url) 
				$responseObj = Invoke-WebRequest -Uri $url
				
				if($responseObj.statusCode -ne 200) {
					write-host "Error Code $($responseObj.statusCode)" -foregroundcolor red -backgroundcolor yellow
				}
				elseif($responseObj.Content -match $pattern) {
					$obj = New-Object psobject
					$matches.keys | Where-Object {$_ -ne 0}  | ForEach {
						$prop = $_
						$value = $matches[$prop] -replace "<.*?>"
						Add-Member -InputObject $obj -MemberType NoteProperty -Name $prop -Value $value
					}	
					$retryCounter = 0
					$obj
				 }
				elseif ($responseObj.Content -match "no zip code found") {
					write-host "$_ zip not found"
					$retryCounter = 0
				}
				elseif ($responseObj.Content -match "You\w* have exceeded \d+ searches today") {
					write-host "Max searches reached" -foregroundcolor red -backgroundcolor yellow
					$retryCounter = 0
				}
				else {
					write-host "pattern mismatch contentLen=$($responseObj.Content.Length) =?= rawLen=$($responseObj.RawContentLength)" -foregroundcolor red -backgroundcolor yellow
					
					##write-host $responseObj.Content
				}
				
			 }
			catch  {
				write-host "Error" + $error -foregroundcolor red -backgroundcolor yellow
				$error.Clear()
			}
			$retryCounter--
		}
	} | Select-Object "zipCode", 
	                  "areaCode", 
	                  "city", 
	                  "stateName", 
	                  "countyName", 
	                  "nearCity", 
	                  "population", 
	                  "houseHoldIncome", 
	                  "avgHouseVal",
	                  "timezone"`
	| Export-Csv $outCsvFile -notype -Delimiter `t
	
}

# Image Source http://vis-www.cs.umass.edu/lfw/#resources
#
function GenerateContactInfo {


	$rootFolder= "c:\temp\images"
	$imageInfoList =
	Get-ChildItem -Path $rootFolder |
		Where-Object { $_.Attributes -eq "Directory" } |		
		ForEach-Object { 
			$name = $_.name
			$nameArray = $name.split("_")
			
			$obj = New-Object psobject
			Add-Member -InputObject $obj -MemberType NoteProperty -Name fname -Value $nameArray[0]
			Add-Member -InputObject $obj -MemberType NoteProperty -Name lname -Value $nameArray[-1]
			Add-Member -InputObject $obj -MemberType NoteProperty -Name mname -Value ""
			
			if ($nameArray -gt 2) {
				$obj.mname = $nameArray[1]
				for ($i=2; $i -lt $nameArray.length-1; $i++) {
					$obj.mname = $obj.mname + " " + $nameArray[$i]
				}
			}
			
			$imagePath = Get-ChildItem -Path "$rootFolder\$name" | 
				Where-Object {$_.Attributes -ne "Directory"} |
				Select -first 1 | ForEach {"$rootFolder\$name\$($_.name)"}
				
				
			Add-Member -InputObject $obj -MemberType NoteProperty -Name imagePath -Value $imagePath
			
			$obj
		}  
		
	# Build a request list
	$requestList = @()
	$counter = 0
	$maxRequestLen = 6000
	$rootRequest = "http://api.genderize.io?"
	$imageInfoList | Foreach-Object { $_.fname.ToLower() } | Select-Object -unique | ForEach-Object {
		$newRequest = "&name[$counter]=$_"
		if (($rootRequest + $request + $newRequest).length -lt $maxRequestLen) {
			$request += $newRequest
			$counter ++
		}
		else {
			$requestList += ($rootRequest + $request)
			$request = $newRequest
			$counter = 0
		}
	}
	$requestList += ($rootRequest + $request)
	
	
	# Get JSON test response
	$jsonResponse = ""
	$requestList | ForEach {
			$responseObj = Invoke-WebRequest -Uri $_
			$retryCount =3
			while ($responseObj.statusCode -ne 200 -and $retryCount-- -gt 0) {
				Start-Sleep -milliseconds 500
				$responseObj = (Invoke-WebRequest -Url $_)
			}
			
			if ($responseObj.statusCode -eq 200) {
				if ($jsonResponse -ne "") {
					$jsonResponse +=","
				}
				$jsonResponse += $responseObj.Content -replace "^\s*\[|\]\s*$", ""
			}
		}
	$jsonResponse = "[$jsonResponse]"
	
	# convert Json array response to hashtable of names so we them up by user
	$genderByName = @{}
	$json = $jsonResponse | ConvertFrom-Json
	$json | ForEach { 
			if (!$genderByName.ContainsKey($_.name)) {
				$genderByName.Add($_.name, $_)
			}
		}
		
	#add genderInfo to imageInfoList
	
	$imageInfoList | 
	ForEach-Object {
		$imageInfo = $_
		Add-Member -InputObject $imageInfo -MemberType NoteProperty -Name gender -Value $null
		Add-Member -InputObject $imageInfo -MemberType NoteProperty -Name genderProbability -Value 0
		$name = $_.fname.ToLower()
		if ($genderByName.containsKey($name)) {	
			$genderInfo = $genderByName.Get_Item($name)
			$ImageInfo.gender = $genderInfo.gender
			$imageInfo.genderProbability = $genderInfo.probability
		}
	}
}


function DownloadAdditionalContact {
	$lnames = @("Johnson","Williams","Brown","Jones","Miller","Davis","Garcia","Rodriguez","Wilson","Martinez","Anderson","Taylor","Thomas","Hernandez","Moore","Martin","Jackson","Thompson","White","Lopez","Lee","Gonzalez","Harris","Clark","Lewis","Robinson","Walker","Perez","Hall","Young","Allen","Sanchez","Wright","King","Scott","Green","Baker","Adams","Nelson","Hill","Ramirez","Campbell","Mitchell","Roberts","Carter","Phillips","Evans","Turner","Torres","Parker","Collins","Edwards","Stewart","Flores","Morris","Nguyen","Murphy","Rivera","Cook","Rogers","Morgan","Peterson","Cooper","Reed","Bailey","Bell","Gomez","Kelly","Howard","Ward","Cox","Diaz","Richardson","Wood","Watson","Brooks","Bennett","Gray","James","Reyes","Cruz","Hughes","Price","Myers","Long","Foster","Sanders","Ross","Morales","Powell","Sullivan","Russell","Ortiz","Jenkins","Gutierrez","Perry","Butler","Barnes","Fisher","Henderson","Coleman","Simmons","Patterson","Jordan","Reynolds","Hamilton","Graham","Kim","Gonzales","Alexander","Ramos","Wallace","Griffin","West","Cole","Hayes","Chavez","Gibson","Bryant","Ellis","Stevens","Murray","Ford","Marshall","Owens","Mcdonald","Harrison","Ruiz","Kennedy","Wells","Alvarez","Woods","Mendoza","Castillo","Olson","Webb","Washington","Tucker","Freeman","Burns","Henry","Vasquez","Snyder","Simpson","Crawford","Jimenez","Porter","Mason","Shaw","Gordon","Wagner","Hunter","Romero","Hicks","Dixon","Hunt","Palmer","Robertson","Black","Holmes","Stone","Meyer","Boyd","Mills","Warren","Fox","Rose","Rice","Moreno","Schmidt","Patel","Ferguson","Nichols","Herrera","Medina","Ryan","Fernandez","Weaver","Daniels","Stephens","Gardner","Payne","Kelley","Dunn","Pierce","Arnold","Tran","Spencer","Peters","Hawkins","Grant","Hansen","Castro","Hoffman","Hart","Elliott","Cunningham","Knight","Bradley")

	$women = @("Mary","Patricia","Linda","Barbara","Elizabeth","Jennifer","Maria","Susan","Margaret","Dorothy","Lisa","Nancy","Karen","Betty","Helen","Sandra","Donna","Carol","Ruth","Sharon","Michelle","Laura","Sarah","Kimberly","Deborah","Jessica","Shirley","Cynthia","Angela","Melissa","Brenda","Amy","Anna","Rebecca","Virginia","Kathleen","Pamela","Martha","Debra","Amanda","Stephanie","Carolyn","Christine","Marie","Janet","Catherine","Frances","Ann","Joyce","Diane","Alice","Julie","Heather","Teresa","Doris","Gloria","Evelyn","Jean","Cheryl","Mildred","Katherine","Joan","Ashley","Judith","Rose","Janice","Kelly","Nicole","Judy","Christina","Kathy","Theresa","Beverly","Denise","Tammy","Irene","Jane","Lori","Rachel","Marilyn","Andrea","Kathryn","Louise","Sara","Anne","Jacqueline","Wanda","Bonnie","Julia","Ruby","Lois","Tina","Phyllis","Norma","Paula","Diana","Annie", "Peggy")

	$men = @("James","John","Robert","Michael","William","David","Richard","Charles","Joseph","Thomas","Christopher","Daniel","Paul","Mark","Donald","George","Kenneth","Steven","Edward","Brian","Ronald","Anthony","Kevin","Jason","Matthew","Gary","Timothy","Jose","Larry","Jeffrey","Frank","Scott","Eric","Stephen","Andrew","Raymond","Gregory","Joshua","Jerry","Dennis","Walter","Patrick","Peter","Harold","Douglas","Henry","Carl","Arthur","Ryan","Roger","Joe","Juan","Jack","Albert","Jonathan","Justin","Terry","Gerald","Keith","Samuel","Willie","Ralph","Lawrence","Nicholas","Roy","Benjamin","Bruce","Brandon","Adam","Harry","Fred","Wayne","Billy","Steve","Louis","Jeremy","Aaron","Randy","Howard","Eugene","Carlos","Russell","Bobby","Victor","Martin","Ernest","Phillip","Todd","Jesse","Craig","Alan","Shawn","Clarence","Sean","Philip","Chris","Johnny","Earl","Jimmy", "Tony")


	$rootPath = "c:\temp\images"
	$j=0
	$imageInfoList2 =	@($women, $men) | ForEach {
		for ($i=0; $i -lt 100 -and $i -lt $_.length; $i++) {
			$obj = New-Object psobject
			Add-Member -InputObject $obj -MemberType NoteProperty -Name fname -Value $_[$i]
			Add-Member -InputObject $obj -MemberType NoteProperty -Name lname -Value $lnames[$j++]
			Add-Member -InputObject $obj -MemberType NoteProperty -Name mname -Value $_[(Get-Random -maximum ($_.length -1))]
			Add-Member -InputObject $obj -MemberType NoteProperty -Name gender -Value "female"
			Add-Member -InputObject $obj -MemberType NoteProperty -Name genderProbability -Value 1.0

			$url = "http://api.randomuser.me/portraits/med/women/$i.jpg"
			
			if ($_[0] -eq $men[0]) { 
				$url = $url -replace "/women/", "/men/" 
				$obj.gender="male"
			}
			
			Add-Member -InputObject $obj -MemberType NoteProperty -Name imageSrc -Value $url
			
			Add-Member -InputObject $obj -MemberType NoteProperty -Name imagePath -Value  "$rootPath\$($obj.fname)_$($obj.mname)_$($obj.lname).jpg"
			$obj
			#Invoke-WebRequest $url -OutFile $dest
		}
	}
	
	
}

<#
 # combine list
$newList = ($imageInfoList2 + $imageInfoList) |
		ForEach-Object {
			$path = $_.imagePath -replace "\\images\\.+\\", "\images\2_"
			$obj = New-Object psobject 
			$obj | Add-Member -MemberType NoteProperty -Name fname -Value $_.fname 
			$obj | Add-Member -MemberType NoteProperty -Name mname -Value $_.mname 
			$obj | Add-Member -MemberType NoteProperty -Name lname -Value $_.lname 
			$obj | Add-Member -MemberType NoteProperty -Name gender -Value $_.gender 
			$obj | Add-Member -MemberType NoteProperty -Name genderProbability -Value  $_.genderProbability 
			$obj | Add-Member -MemberType NoteProperty -Name imagePath -Value $path
			
			$obj
		}
	
#>

