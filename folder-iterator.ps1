# A "DoSomethingFunction" is required
# Do not use this script directly
# It's designed to call by other powershell script

function FolderIterator {
	param (
		$SourceFolder,
		$OutputFolder,
		# Filter file extension name
		# .wav
		# .*
		$SourceFileType,
		# 2nd format, use only with rare situation
		$SourceFileType2 = $SourceFileType
	)

	# Check source folder exist
	if(! (Test-Path -LiteralPath $sourceFolder) ){
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
		Remove-Item -LiteralPath $writePermissionTestFile | Out-Null
	}
	catch{
		"ERROR: Something happed while creating output folder."
		"ERR: 1"
		$_.Exception|format-list -force
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
		$_.Exception|format-list -force
		exit
	}

	# Print source & output folder path after error check
	"Source: $sourceFolder"
	"Output: $outputFolder`n"

	try{
		# Loop through fileset
		foreach ($mySourceFileObj in $myFileSet)
		{
			# Save source file full path
			$mySourceFile="$SourceFolder\" + $mySourceFileObj.Name

			# Save output file name without extension name
			$myOutFileName="$outputFolder\" + [io.path]::GetFileNameWithoutExtension($mySourceFileObj.Name)

			# Function call to do something with this file
			DoSomethingFunction -InputFile $mySourceFile -OutputFileName $myOutFileName
		}
	}
	catch{
		"ERROR: Something happend while run sub script."
		"ERR: 3"
		$_.Exception|format-list -force
		exit
	}
}