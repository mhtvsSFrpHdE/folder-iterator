# Preset argument
$sourceFolder="C:\"
$outputFolder="C:\out"
# Filter file extension name
$sourceFileType=".wav"
# 2nd format, use only whth rare situation
$sourceFileType2=$sourceFileType



# Check source folder exist
if(! (Test-Path $sourceFolder) ){
	"ERROR: Source folder isn't exist."
	"ERR: 0"
	exit
}

try{
	# Create this output folder
	New-Item -Path "$outputFolder" -ItemType Directory -Force | Out-Null

	# Save temp write permission test file path
	# Have a random name to prevent overwrite user file
	$writePermissionTestFile = "$outputFolder\EmptyFileU3wlq40D6NuP.txt"
	# Create test file
	New-Item -Path $writePermissionTestFile -ItemType File | Out-Null
	# Delete test file
	Remove-Item -Path $writePermissionTestFile | Out-Null
}
catch{
	"ERROR: Something happed while creating output folder."
	"ERR: 1"
	exit
}


try{
	# Get file from subfolder | Filter extension name | Select name
	# Where match multi: where Name -match "a|b"
	$myFileSet = Get-ChildItem -literalpath $sourceFolder -file | where Name -match "^*\$sourceFileType|^*\$sourceFileType2" | Select-Object name
}
catch{
	"ERROR: Something happed while listing files."
	"ERR: 2"
	exit
}

# Print source & output folder path after error check
"Source: $sourceFolder"
"Output: $outputFolder`n"

try{
	# Loop through fileset
	foreach ($mySourceFileObj in $myFileSet)
	{
		# Save file full path
		$mySourceFile=$mySourceFileObj.Name
		# Print
		"File: $mySourceFile"
		
		$myCommand="""$sourceFolder\$mySourceFile"""
		# Print
		"Run: $myCommand`n"
	}
}
catch{
	"ERROR: Something happend while run sub script."
	"ERR: 3"
	exit
}

exit