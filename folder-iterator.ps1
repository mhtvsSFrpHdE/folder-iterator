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
        $InputFileType = ".*",
        # 2nd format, use only with rare situation
        $InputFileType2 = $InputFileType,
        [switch] $Recurse = $false,
        [switch] $Verbose = $false
    )

    # Check input folder exist
    if (! (Test-Path -LiteralPath $InputFolder) ) {
        Write-Error "ERROR: Input folder isn't exist."
        Write-Error "ERR: 0"
		
        return $false
    }

    # Print input & output folder path after error check
    if ($Verbose) {
        Write-Output "Input: $InputFolder"
        Write-Output "Output: $OutputFolder`n"
    }
	
    #TODO this is not work
    # Generate output folder struct
    try {
        if ($OutputFolder -ne $false) {
            # Create this output folder
            New-Item -Path "$OutputFolder" -ItemType Directory -Force | Out-Null

            # Export temp write permission test file path
            # Add a random name suffix to prevent overwrite user file
            $writePermissionTestFile = Join-Path $OutputFolder "EmptyFileU3wlq40D6NuP.txt"
            # Create test file
            New-Item -Path $writePermissionTestFile -ItemType File | Out-Null
            # Delete test file
            Remove-Item -LiteralPath $writePermissionTestFile | Out-Null
        }
    }
    catch {
        $_.Exception | Format-List -Force
        Write-Error "ERROR: Something happed while creating output folder."
        Write-Error "ERR: 1"
		
        return $false
    }


    try {
        # Get file and folder from subfolder | Filter extension name | Select full name
        # Where match multi: where Name -match "a|b"
        # Select FullName vs Name is give full path or not
        $myFileSet = Get-ChildItem -LiteralPath $InputFolder -File | Where-Object Name -Match "^*\$InputFileType|^*\$InputFileType2" | Select-Object FullName
        $myFolderSet = Get-ChildItem -LiteralPath $InputFolder -Directory | Select-Object FullName
    }
    catch {
        $_.Exception | Format-List -Force
        Write-Error "ERROR: Something happed while listing files."
        Write-Error "ERR: 2"
		
        return $false
    }



    try {
        # Loop through fileset
        foreach ($myInputFileObj in $myFileSet) {
            # Save input file full path
            $myInputFileFullPath = $myInputFileObj.FullName

            $myOutputFileNameWithoutExtension = [io.path]::GetFileNameWithoutExtension($myInputFileObj.FullName)
            $myOutputFileNameWithoutExtensionAndPath = Split-Path $myOutputFileNameWithoutExtension -Leaf

            # Save output file name without extension name
            $myOutputFile = $myInputFileFullPath, $myOutputFileNameWithoutExtension, $myOutputFileNameWithoutExtensionAndPath

            # Function call to do something with this file
            # API: -InputFile just need to be a normal file name with full path
            #	-OutputFileArray define a array [0] is file name with full path
            #	[1] is file name with full path but without file extension
            #	[2] is just file name without full path and file extension
            DoSomethingFunction -InputFile $myInputFileFullPath -OutputFileArray $myOutputFile
        }

        # Loop through folderset
        # If Recurse + no OutputFolder + myFolderSet count > 0
        if ( ($Recurse -and ($OutputFolder -eq $false) ) -and ($myFolderSet.FullName.Count -gt 0) ) {
            foreach ($myInputFolderObj in $myFolderSet) {
                FolderIterator -InputFolder $myInputFolderObj.FullName -InputFileType $InputFileType -InputFileType2 $InputFileType2 -Recurse
            }
        }
    }
    catch {
        $_.Exception | Format-List -Force
        Write-Error "ERROR: Something happend while run sub script."
        Write-Error "ERR: 3"
		
        return $false
    }
}