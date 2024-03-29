﻿Clear-Host

#configuration file
$jsonfile_name = "backup_projects.json"
$logFilePath = "backup_log.txt"

# Read the JSON file
try {
    $jsonContent = Get-Content -Path $jsonfile_name | ConvertFrom-Json
}
catch {
    Write-Host "An unexpected error occurred: $($_.Exception.Message)"
    exit
}

Write-Host "`nIt backs up the files in the directory tree of the source to the destination directory."
Write-Host "The directories that can be backed up are stored in the file $jsonfile_name."
Write-Host "To change the current list of directories, you must modify the file $jsonfile_name with a plain text editor."
Write-Host "A log file is saved at the end of the process with the name $logFilePath"

Write-Host "`nAvailable directories.`n"
# Iterate through the keys and display source and destination attributes
foreach ($key in $jsonContent.PSObject.Properties) {
    Write-Host "Key: $($key.Name) ,  Source: $($key.Value.source) ,  Destination: $($key.Value.destination)`n"
}

# Prompt the user to enter the key or exit
$selectedKey = Read-Host "`nType the key of the directory to back up"

$quitStrs = 'e', 'q', '0', 'exit', 'quit'
# Check if the user wants to exit
if ($quitStrs -contains $selectedKey) {
    Write-Host "`nProcess terminated by the user.`n"
    exit
}

Clear-Host

# Read the JSON file again
$jsonContent = Get-Content -Path $jsonfile_name | ConvertFrom-Json

if ($jsonContent.PSObject.Properties[$selectedKey]) {
    $selectedItem = $jsonContent.$selectedKey

    # Initialize variables
    $source = $selectedItem.source
    $destination = $selectedItem.destination
    $exclude_dirs = $selectedItem.exclude_dirs

    # Display the values
    Write-Host "`nSelected directory"
    Write-Host "Key: $selectedKey"
    Write-Host "Source: $source"
    Write-Host "Destination: $destination"
    if ($exclude_dirs.Count -gt 0){
        Write-Host "Excluded directories"
        foreach ($item in $exclude_dirs) {
             Write-Host $item
        }
    }
} else {
    Write-Host "`nKey '$selectedKey' not found. Process terminated.`n"
    exit
}

# Test if the paths exist and and are directories
Write-Host "`nChecking directories."
$directories = @($source, $destination)
if ($exclude_dirs.Count -gt 0) {
    $directories = @($source, $destination) + $exclude_dirs
}
$ifaults = 0
foreach ($directory in $directories) {
    if (Test-Path -Path $directory -PathType Container) {
        # Write-Host "Directory '$directory' exists and is a directory."
    } elseif (Test-Path -Path $directory) {
        Write-Host "Path '$directory' exists but is not a directory."
        $ifaults += 1
    } else {
        Write-Host "Path '$directory' does not exist."
        $ifaults += 1
    }
}

if ($ifaults -gt 0){
    Write-Host "`nRemove non-existent directories from $jsonfile_name and try again.`n"
    exit
}


if ($exclude_dirs.Count -gt 0){
    $xd_opt = @("/XD", $exclude_dirs)
} else {
    $xd_opt = ""
}


# Display options
Write-Host "`nOptions."
Write-Host "1. Preview (doesn't copy anything)."
Write-Host "2. Backup the source directory tree."
Write-Host "Other: Quit."
# Ask to continue with the execution of the script
$action = Read-Host -Prompt "`nType an option to continue."

$base_options = "/IT", "/R:1", "/W:1", "/np", "/NDL", "/E"

if ($action -eq "1") {
    robocopy $source $destination $base_options $xd_opt /L /LOG:$logFilePath
}
elseif ($action -eq "2") {
    robocopy $source $destination $base_options $xd_opt /LOG:$logFilePath
}
else {
    Write-Host "`nTask cancelled by the user.`n"
    exit
}

Write-Host "`nTask completed successfully.`n"

