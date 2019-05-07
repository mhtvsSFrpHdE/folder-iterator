# A "DoSomethingFunction" is required
# Do not use this script directly
# It's designed to call by other powershell script

function FolderIterator {
	param (
		$InputFolder,
		$OutputFolder,
		# Filter file extension name
		# .wav
		# .*
		$InputFileType,
		# 2nd format, use only with rare situation
		$InputFileType2 = $InputFileType
	)

	# Check input folder exist
	if(! (Test-Path -LiteralPath $InputFolder) ){
		"ERROR: Input folder isn't exist."
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
		$myFileSet = Get-ChildItem -literalpath $InputFolder -file | where Name -match "^*\$InputFileType|^*\$InputFileType2" | Select-Object name
	}
	catch{
		"ERROR: Something happed while listing files."
		"ERR: 2"
		$_.Exception|format-list -force
		exit
	}

	# Print input & output folder path after error check
	"Input: $InputFolder"
	"Output: $outputFolder`n"

	try{
		# Loop through fileset
		foreach ($myInputFileObj in $myFileSet)
		{
			# Save input file full path
			$myInputFile="$InputFolder\" + $myInputFileObj.Name

			# Save output file name without extension name
			$myOutFileName="$outputFolder\" + [io.path]::GetFileNameWithoutExtension($myInputFileObj.Name)

			# Function call to do something with this file
			DoSomethingFunction -InputFile $myInputFile -OutputFileName $myOutFileName
		}
	}
	catch{
		"ERROR: Something happend while run sub script."
		"ERR: 3"
		$_.Exception|format-list -force
		exit
	}
}