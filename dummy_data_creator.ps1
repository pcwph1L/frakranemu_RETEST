# Parameters
$baseFolder = "C:\Users\retest2\DummyData" # Change to your desired base directory
$fileCount = 1000               # Number of files for each extension

# Create the base directory if it does not exist
if (-Not (Test-Path -Path $baseFolder)) {
    New-Item -ItemType Directory -Path $baseFolder | Out-Null
}

# Array of file extensions
$fileExtensions = @(".doc", ".docx", ".pdf", ".ppt", ".pptx", ".txt", ".xls")

# Generate dummy files
foreach ($extension in $fileExtensions) {
    # Create a subfolder for each file type
    $subfolderName = $extension.TrimStart('.').ToUpper() # Use extension as folder name
    $subfolderPath = Join-Path -Path $baseFolder -ChildPath $subfolderName

    if (-Not (Test-Path -Path $subfolderPath)) {
        New-Item -ItemType Directory -Path $subfolderPath | Out-Null
    }

    # Generate files within the subfolder
    for ($i = 1; $i -le $fileCount; $i++) {
        $fileName = "DummyFile_$i$extension"
        $filePath = Join-Path -Path $subfolderPath -ChildPath $fileName

        # Create a dummy file with some content
        $content = "This is a dummy ${extension} file generated on $(Get-Date)."

        try {
            # Set content with encoding UTF-8 to handle special characters in path
            Set-Content -Path $filePath -Value $content -Encoding UTF8
        } catch {
            Write-Host "Error creating file ${filePath}: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "Dummy files created successfully in $baseFolder"
