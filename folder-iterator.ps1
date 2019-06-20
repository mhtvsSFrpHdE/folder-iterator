# A "DoSomethingFunction" is required
# Do not use this script directly
# It's designed to call by other powershell script

function FolderIterator {
	param (
		$InputFolder,
		$OutputFolder = $false,
		# Filter file extension name
		# .wav
		# .*
		$InputFileType,
		# 2nd format, use only with rare situation
		$InputFileType2 = $InputFileType,
		[switch] $Recurse = $false
	)

	# Check input folder exist
	if(! (Test-Path -LiteralPath $InputFolder) ){
		Write-Error "ERROR: Input folder isn't exist."
		Write-Error "ERR: 0"
		
		return $false
	}

	try{
		if($OutputFolder -ne $false){
			# Create this output folder
			New-Item -Path "$outputFolder" -ItemType Directory -Force | Out-Null

			# Export temp write permission test file path
			# Add a random name suffix to prevent overwrite user file
			$writePermissionTestFile = "$outputFolder\EmptyFileU3wlq40D6NuP.txt"
			# Create test file
			New-Item -Path $writePermissionTestFile -ItemType File | Out-Null
			# Delete test file
			Remove-Item -LiteralPath $writePermissionTestFile | Out-Null
		}
	}
	catch{
		$_.Exception | Format-List -Force
		Write-Error "ERROR: Something happed while creating output folder."
		Write-Error "ERR: 1"
		
		return $false
	}


	try{
		# Get file from subfolder | Filter extension name | Select name
		# Where match multi: where Name -match "a|b"
		$myFileSet = Get-ChildItem -LiteralPath $InputFolder -File | Where-Object Name -Match "^*\$InputFileType|^*\$InputFileType2" | Select-Object Name
	}
	catch{
		$_.Exception | Format-List -Force
		Write-Error "ERROR: Something happed while listing files."
		Write-Error "ERR: 2"
		
		return $false
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
		$_.Exception | Format-List -Force
		Write-Error "ERROR: Something happend while run sub script."
		Write-Error "ERR: 3"
		
		return $false
	}
}