function Get-MagicNumber
{ 	
	$db = @{
	'.zip'='504B';'.docx'='504B';'.pptx'='504B';'.xlsx'='504B';'.vsdx'='504B';'.jar'='504B';'.apk'='504B'
	'.msi'='D0CF';'.doc'='D0CF';'.ppt'='D0CF';'.xls'='D0CF';'.vsd'='D0CF';'.msg'='D0CF'
	'.pdf'='2550'
	'.exe'='4D5A';'.dll'='4D5A'
	'.lnk'='4C00'
	'.jpg'='FFD8';'.jpeg'='FFD8'
	'.png'='8950'
	'.gif'='4749'
	'.bmp'='424D'
	'.mp3'='4944'
	'.flac'='664C'
	'.midi'='4D54'
	'.mp4'='6674';'.m4v'='6674';'.mov'='6674';'.flv'='6674';'.m4a'='6674'
	'.avi'='5249'
	'.asf'='3026';'.wmv'='3026';'.wma'='3026'
	'.rar'='5261'
	'.7z'='377A'
	'.tar'='7573'
	'.gz'='1F8B'
	'.pcap'='D4C3'
	'.php'='3C3F';'.xml'='3C3F';'.vcxproj'='3C3F';'.wpl'='3C3F'
	'.html'='3C21/3C68/EFBB'
	'.sql'='2D2D'
	#'py'='696D';'java'='696D'
	'class'='CAFE'
	'c'='2369';'cpp'='2369'
	'sln'='EFBB';'user'='EFBB';'filters'='EFBB'
	'idb'='4D69';'pdb'='4D69';'ilk'='4D69'
	'obj'='4C01'
	'ps'='2521'}
	$native = $env:USERPROFILE
	$target = $native + '\Desktop\test'
	$FileName = Get-ChildItem -path $target -recurse 
	$ExportCSVFileName = "extMagic.csv"
	#counter
	$CountObj = 0
	$ObjArray = @()
	
	foreach($fn in $FileName) {
			if($db.keys -contains $fn.extension) {
				$magicnumber = Get-Content -encoding byte $fn -read 2 -total 2
				$hex = ("{0:x}" -f ($magicnumber[0] * 256 + $magicnumber[1]))
				#"{0}" -f $hex}
				if ($db.values -contains $hex) {
					Write-host 'Magic number match! Moving to next file!'
				}
				else {
					Write-host 'Magic Number no match!' $ext
				}    
				}
			else {
				write-host 'This extension is not in the list of magic number'
			}
	}	
}

Get-MagicNumber