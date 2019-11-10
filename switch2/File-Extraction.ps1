$date = Get-Date
$date = $date.ToString('').Replace(":",",")
$date = $date.Replace(" ",",")
$date = $date.Replace("/",",")

#Set the loot directory for bash bunny
$dir_bash = (Get-Volume -FileSystemLabel BashBunny).DriveLetter
$dir = $dir_bash + ':\loot'
new-item "$($dir)\Files-$($date)" -ItemType directory
$dir = "$($dir)\Files-$($date)"

Function getItAll
{	
	$extdb = @{
	'.zip'='504B';'.docx'='504B';'.pptx'='504B';'.xlsx'='504B';'.vsdx'='504B';'.jar'='504B';'.apk'='504B';'.mwb'='504B'
	'.msi'='D0CF';'.doc'='D0CF';'.ppt'='D0CF';'.xls'='D0CF';'.vsd'='D0CF';'.mpp'='D0CF';'.suo'='D0CF'
	'.pdf'='2550'
	'.exe'='4D5A';'.dll'='4D5A';'.pyd'='4D54'
	'.lnk'='4C00'
	'.jpg'='FFD8';'.jpeg'='FFD8'
	'.png'='8950'
	'.gif'='4749'
	'.bmp'='424D'
	'.mp3'='4944'
	'.flac'='664C'
	'.midi'='4D54'
	#'.mp4'='6674'
	'.m4v'='6674';'.mov'='6674';'.flv'='6674';'.m4a'='6674'
	'.avi'='5249'
	'.asf'='3026';'.wmv'='3026';'.wma'='3026'
	'.rar'='5261'
	'.7z'='377A'
	'.tar'='7573'
	'.gz'='1F8B'
	'.pcap'='D4C3'
	#'.php'='3C3F';'.xml'='3C3F';'.vcxproj'='3C3F';'.wpl'='3C3F'
	#'.html'='3C21/3C68/EFBB'
	#'.sql'='2D2D'
	#'py'='696D';'java'='696D'
	'.class'='CAFE'
	#'.c'='2369';'.cpp'='2369'
	#'.sln'='EFBB';'.user'='EFBB';'.filters'='EFBB'
	#'.idb'='4D69';'.pdb'='4D69';'.ilk'='4D69'
	#'.obj'='4C01'
	'.ps'='2521'}
	$db = Get-Content -path "malicious_db.txt"
	$target = $env:USERPROFILE
	#$target = $native + '\Desktop'
	$FileName = Get-ChildItem -file -path $target -recurse -Force  #-ErrorAction SilentlyContinue 
	$ExportCSVFileName = "$($dir)\getall.csv"
	[Void][Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')
	#counter
	$CountObj = 0
	$ObjArray = @()
	foreach($fn in $FileName) {
		if ($fn.extension -eq ('.zip')) {
			if(Test-Path ($fn.FullName)) {
				$CountObj += 1
				$RawFiles = [IO.Compression.ZipFile]::OpenRead($fn.FullName).Entries
			} else {
				$CountObj += 1
				$RawFiles = [IO.Compression.ZipFile]::OpenRead($fn.FullName).Entries
			}
			foreach($RawFile in $RawFiles) {
				if ($db -contains([System.IO.Path]::GetExtension($RawFile.FullName))) {
					$CountObj += 1
					$Object = New-Object -TypeName PSObject            
					$Object | Add-Member -MemberType NoteProperty -Name Count -Value $CountObj
					$Object | Add-Member -MemberType NoteProperty -Name Result -Value 'File retrieved from zip' 
					$Object | Add-Member -MemberType NoteProperty -Name Time -Value $fn.LastAccessTime
					$Object | Add-Member -MemberType NoteProperty -Name Title -Value $RawFile.Name            
					$Object | Add-Member -MemberType NoteProperty -Name FullPath -Value $RawFile.FullName                       
					$Object | Add-Member -MemberType NoteProperty -Name LengthInKB -Value ($RawFile.Length/1KB).Tostring("00")            
					$Object | Add-Member -MemberType NoteProperty -Name HexSignature -Value 'No hex value retrieved for files in zip'  
					$Object | Add-Member -MemberType NoteProperty -Name FileExtn -Value ([System.IO.Path]::GetExtension($RawFile.FullName))
					$Object | Add-Member -MemberType NoteProperty -Name PotentiallyMalicious -Value '1'
					$Object | Add-Member -MemberType NoteProperty -Name ExtNoMatch -Value '0'
					$ObjArray += $Object            
					if(!$ExportCSVFileName) {            
					$Object            
					}
				} else {
					$CountObj += 1
					$Object = New-Object -TypeName PSObject            
					$Object | Add-Member -MemberType NoteProperty -Name Count -Value $CountObj
					$Object | Add-Member -MemberType NoteProperty -Name Result -Value 'File retrieved from zip' 
					$Object | Add-Member -MemberType NoteProperty -Name Time -Value $fn.LastAccessTime
					$Object | Add-Member -MemberType NoteProperty -Name Title -Value $RawFile.Name            
					$Object | Add-Member -MemberType NoteProperty -Name FullPath -Value $RawFile.FullName                       
					$Object | Add-Member -MemberType NoteProperty -Name LengthInKB -Value ($RawFile.Length/1KB).Tostring("00")            
					$Object | Add-Member -MemberType NoteProperty -Name HexSignature -Value 'No hex value retrieved for files in zip'  
					$Object | Add-Member -MemberType NoteProperty -Name FileExtn -Value ([System.IO.Path]::GetExtension($RawFile.FullName))
					$Object | Add-Member -MemberType NoteProperty -Name PotentiallyMalicious -Value '0'
					$Object | Add-Member -MemberType NoteProperty -Name ExtNoMatch -Value '0'
					$ObjArray += $Object            
					if(!$ExportCSVFileName) {            
					$Object            
					}
				}
			}
	} else {
			$magicnumber = Get-Content -encoding byte $fn.FullName -read 2 -total 2 -ErrorAction SilentlyContinue
			$hex = ("{0:x}" -f ($magicnumber[0] * 256 + $magicnumber[1]))
			if ($db -contains $fn.extension) {
				if($extdb.Contains($fn.extension)) {
					if ($extdb.($fn.extension) -contains ($hex)) {					
						$CountObj += 1
						$Object = New-Object -TypeName PSObject            
						$Object | Add-Member -MemberType NoteProperty -Name Count -Value $CountObj
						$Object | Add-Member -MemberType NoteProperty -Name Result -Value 'Extension matches magic number' 
						$Object | Add-Member -MemberType NoteProperty -Name Time -Value $fn.LastAccessTime
						$Object | Add-Member -MemberType NoteProperty -Name Title -Value $fn.Name            
						$Object | Add-Member -MemberType NoteProperty -Name FullPath -Value $fn.FullName                       
						$Object | Add-Member -MemberType NoteProperty -Name LengthInKB -Value ($fn.Length/1KB).Tostring("00")            
						$Object | Add-Member -MemberType NoteProperty -Name HexSignature -Value $hex  
						$Object | Add-Member -MemberType NoteProperty -Name FileExtn -Value ([System.IO.Path]::GetExtension($fn.FullName))
						$Object | Add-Member -MemberType NoteProperty -Name PotentiallyMalicious -Value '1'
						$Object | Add-Member -MemberType NoteProperty -Name ExtNoMatch -Value '0'
						$ObjArray += $Object            
						if(!$ExportCSVFileName) {            
						$Object            
						}
					} else {
						$CountObj += 1
						$Object = New-Object -TypeName PSObject            
						$Object | Add-Member -MemberType NoteProperty -Name Count -Value $CountObj
						$Object | Add-Member -MemberType NoteProperty -Name Result -Value 'Extension does not match magic number' 
						$Object | Add-Member -MemberType NoteProperty -Name Time -Value $fn.LastAccessTime
						$Object | Add-Member -MemberType NoteProperty -Name Title -Value $fn.Name            
						$Object | Add-Member -MemberType NoteProperty -Name FullPath -Value $fn.FullName                       
						$Object | Add-Member -MemberType NoteProperty -Name LengthInKB -Value ($fn.Length/1KB).Tostring("00")            
						$Object | Add-Member -MemberType NoteProperty -Name HexSignature -Value $hex  
						$Object | Add-Member -MemberType NoteProperty -Name FileExtn -Value ([System.IO.Path]::GetExtension($fn.FullName))
						$Object | Add-Member -MemberType NoteProperty -Name PotentiallyMalicious -Value '1'
						$Object | Add-Member -MemberType NoteProperty -Name ExtNoMatch -Value '1'
						$ObjArray += $Object            
						if(!$ExportCSVFileName) {            
						$Object            
						}
					}	
				} elseif ($extdb.Values -contains $hex) {
					$CountObj += 1
					$Object = New-Object -TypeName PSObject            
					$Object | Add-Member -MemberType NoteProperty -Name Count -Value $CountObj
					$Object | Add-Member -MemberType NoteProperty -Name Result -Value 'Magic number does not match extension'
					$Object | Add-Member -MemberType NoteProperty -Name Time -Value $fn.LastAccessTime
					$Object | Add-Member -MemberType NoteProperty -Name Title -Value $fn.Name            
					$Object | Add-Member -MemberType NoteProperty -Name FullPath -Value $fn.FullName                       
					$Object | Add-Member -MemberType NoteProperty -Name LengthInKB -Value ($fn.Length/1KB).Tostring("00")            
					$Object | Add-Member -MemberType NoteProperty -Name HexSignature -Value $hex
					$Object | Add-Member -MemberType NoteProperty -Name FileExtn -Value ([System.IO.Path]::GetExtension($fn.FullName))
					$Object | Add-Member -MemberType NoteProperty -Name PotentiallyMalicious -Value '1'
					$Object | Add-Member -MemberType NoteProperty -Name ExtNoMatch -Value '1'
					$ObjArray += $Object
				} else {
					Write-host $fn 'has an extension that is not in our database' -foregroundcolor yellow
					$CountObj += 1
					$Object = New-Object -TypeName PSObject            
					$Object | Add-Member -MemberType NoteProperty -Name Count -Value $CountObj
					$Object | Add-Member -MemberType NoteProperty -Name Result -Value 'Extension not in DB'
					$Object | Add-Member -MemberType NoteProperty -Name Time -Value $fn.LastAccessTime
					$Object | Add-Member -MemberType NoteProperty -Name Title -Value $fn.Name            
					$Object | Add-Member -MemberType NoteProperty -Name FullPath -Value $fn.FullName                       
					$Object | Add-Member -MemberType NoteProperty -Name LengthInKB -Value ($fn.Length/1KB).Tostring("00")            
					$Object | Add-Member -MemberType NoteProperty -Name HexSignature -Value $hex
					$Object | Add-Member -MemberType NoteProperty -Name FileExtn -Value ([System.IO.Path]::GetExtension($fn.FullName))
					$Object | Add-Member -MemberType NoteProperty -Name PotentiallyMalicious -Value '1'
					$Object | Add-Member -MemberType NoteProperty -Name ExtNoMatch -Value '0'
					$ObjArray += $Object	
				}
			} else {
				if($extdb.Contains($fn.extension)) {
					if ($extdb.($fn.extension) -contains ($hex)) {					
						Write-host  $fn.Name 'has a valid extension and magic number!' -foregroundcolor green
						$CountObj += 1
						$Object = New-Object -TypeName PSObject            
						$Object | Add-Member -MemberType NoteProperty -Name Count -Value $CountObj
						$Object | Add-Member -MemberType NoteProperty -Name Result -Value 'Extension matches magic number' 
						$Object | Add-Member -MemberType NoteProperty -Name Time -Value $fn.LastAccessTime
						$Object | Add-Member -MemberType NoteProperty -Name Title -Value $fn.Name            
						$Object | Add-Member -MemberType NoteProperty -Name FullPath -Value $fn.FullName                       
						$Object | Add-Member -MemberType NoteProperty -Name LengthInKB -Value ($fn.Length/1KB).Tostring("00")            
						$Object | Add-Member -MemberType NoteProperty -Name HexSignature -Value $hex  
						$Object | Add-Member -MemberType NoteProperty -Name FileExtn -Value ([System.IO.Path]::GetExtension($fn.FullName))
						$Object | Add-Member -MemberType NoteProperty -Name PotentiallyMalicious -Value '0'
						$Object | Add-Member -MemberType NoteProperty -Name ExtNoMatch -Value '0'
						$ObjArray += $Object            
						if(!$ExportCSVFileName) {            
						$Object            
						}
					} else {
						$CountObj += 1
						$Object = New-Object -TypeName PSObject            
						$Object | Add-Member -MemberType NoteProperty -Name Count -Value $CountObj
						$Object | Add-Member -MemberType NoteProperty -Name Result -Value 'Extension does not match magic number' 
						$Object | Add-Member -MemberType NoteProperty -Name Time -Value $fn.LastAccessTime
						$Object | Add-Member -MemberType NoteProperty -Name Title -Value $fn.Name            
						$Object | Add-Member -MemberType NoteProperty -Name FullPath -Value $fn.FullName                       
						$Object | Add-Member -MemberType NoteProperty -Name LengthInKB -Value ($fn.Length/1KB).Tostring("00")            
						$Object | Add-Member -MemberType NoteProperty -Name HexSignature -Value $hex  
						$Object | Add-Member -MemberType NoteProperty -Name FileExtn -Value ([System.IO.Path]::GetExtension($fn.FullName))
						$Object | Add-Member -MemberType NoteProperty -Name PotentiallyMalicious -Value '0'
						$Object | Add-Member -MemberType NoteProperty -Name ExtNoMatch -Value '1'
						$ObjArray += $Object            
						if(!$ExportCSVFileName) {            
						$Object            
						}
					}	
				} elseif ($extdb.Values -contains $hex) {
					$CountObj += 1
					$Object = New-Object -TypeName PSObject            
					$Object | Add-Member -MemberType NoteProperty -Name Count -Value $CountObj
					$Object | Add-Member -MemberType NoteProperty -Name Result -Value 'Magic number does not match extension'
					$Object | Add-Member -MemberType NoteProperty -Name Time -Value $fn.LastAccessTime
					$Object | Add-Member -MemberType NoteProperty -Name Title -Value $fn.Name            
					$Object | Add-Member -MemberType NoteProperty -Name FullPath -Value $fn.FullName                       
					$Object | Add-Member -MemberType NoteProperty -Name LengthInKB -Value ($fn.Length/1KB).Tostring("00")            
					$Object | Add-Member -MemberType NoteProperty -Name HexSignature -Value $hex
					$Object | Add-Member -MemberType NoteProperty -Name FileExtn -Value ([System.IO.Path]::GetExtension($fn.FullName))
					$Object | Add-Member -MemberType NoteProperty -Name PotentiallyMalicious -Value '0'
					$Object | Add-Member -MemberType NoteProperty -Name ExtNoMatch -Value '1'
					$ObjArray += $Object
				} else {
					Write-host $fn 'has an extension that is not in our database' -foregroundcolor yellow
					$CountObj += 1
					$Object = New-Object -TypeName PSObject            
					$Object | Add-Member -MemberType NoteProperty -Name Count -Value $CountObj
					$Object | Add-Member -MemberType NoteProperty -Name Result -Value 'Extension not in DB'
					$Object | Add-Member -MemberType NoteProperty -Name Time -Value $fn.LastAccessTime
					$Object | Add-Member -MemberType NoteProperty -Name Title -Value $fn.Name            
					$Object | Add-Member -MemberType NoteProperty -Name FullPath -Value $fn.FullName                       
					$Object | Add-Member -MemberType NoteProperty -Name LengthInKB -Value ($fn.Length/1KB).Tostring("00")            
					$Object | Add-Member -MemberType NoteProperty -Name HexSignature -Value $hex
					$Object | Add-Member -MemberType NoteProperty -Name FileExtn -Value ([System.IO.Path]::GetExtension($fn.FullName))
					$Object | Add-Member -MemberType NoteProperty -Name PotentiallyMalicious -Value '0'
					$Object | Add-Member -MemberType NoteProperty -Name ExtNoMatch -Value '0'
					$ObjArray += $Object	
					
				}
			}	
			
		
		}
	}
	#==========================================================================================================
	if ($ExportCSVFileName){            
	 try {            
	  $ObjArray  | Export-CSV -Path $ExportCSVFileName -NotypeInformation            
	 } catch {            
	  Write-Error "Failed to export the output to CSV. Details : $_"            
	 }            
	} 
	Write-host 'Extraction concluded!'
	Write-host 'Total unique files on system:' $CountObj

}

#==============================================================================================================
getItAll