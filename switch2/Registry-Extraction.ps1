$date = Get-Date
$date = $date.ToString('').Replace(":",",")
$date = $date.Replace(" ",",")
$date = $date.Replace("/",",")

#Set the loot directory for bash bunny
$dir = (Get-Volume -FileSystemLabel BashBunny).DriveLetter + ':\loot'
new-item "$($dir)\Registry-$($date)" -ItemType directory
$dir = "$($dir)\Registry-$($date)"

# Extract Installed Programs
Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | where{$_.displayname -ne$null}  | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Export-Csv -Path "$($dir)\SoftwareInstalled.csv" -NoTypeInformation

# Extract Most Recently Used
$mru = Get-ItemProperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs"
$objectCollection=@()  
if ($mru) {             
    $mrulistex = $mru.psobject.Properties["MRUListEx"].Value     
    
    # This will hold the hex values that point to the differnt reccently used documents     
    $mrulistexArray = @()     
    
    # Create an array of hex values that correspond to the keys in the hive     
    $i = 0     
    while ($i -lt $mrulistex.length -and $mrulistex.length -ge 4) {         
        $tempstring = "{0:x2}" -f $mrulistex[$i+3]         
        $tempstring += "{0:x2}" -f $mrulistex[$i+2]        
        $tempstring += "{0:x2}" -f $mrulistex[$i+1]        
        $tempstring += "{0:x2}" -f $mrulistex[$i]
        $mrulistexArray += $tempstring         
        $i += 4     
	}       
        # Loop through each key listed by the mrulistex list     
        $i = 0     
        while($mrulistexArray[$i].CompareTo("ffffffff")) {         

            # Read in the value, Powershell reads them in as decimals         
            $decimal = $mru.psobject.Properties[([CONVERT]::toint32($mrulistexArray[$i],16))].Value         
            $hexarray = @()         
            # Read a byte at a time till null.         
            $j = 0         
            for($j -lt $decimal.length) {             
                # Break at the first null character             
                if($decimal[$j+1] -eq 0 -and $decimal[$j] -eq 0) { break }             
                
                # Grab a byte             
                $tempstring = "{0:x2}" -f 
                $decimal[$j+1]             
                $tempstring += "{0:x2}" -f 
                $decimal[$j]            
                # And add it to the hex array             
                $hexarray += $tempstring             
                # Jump forward a byte             
                $j+=2         
			}         
				$object = New-Object PSObject 
                $namearray = $hexarray | foreach {( [CHAR][BYTE]([CONVERT]::toint32($_,16)))}         
					# Char array to String
					$namearray = -join $namearray
					$object | Add-Member -type NoteProperty -Name MRU -Value $namearray
					$objectCollection += $object				
                    $i++     
       } 
				$objectCollection | Export-Csv -Path "$($dir)\mru.csv" -NoTypeInformation
			
}  
                    
else { WRITE-HOST "There are no recently used documents in the registry" }