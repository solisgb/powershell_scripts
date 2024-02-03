# Create a new Windows Principal object
$WindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$WindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($WindowsID)

# Get the security principal for the Administrator role
$AdminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently NOT running as an administrator
if (-not $WindowsPrincipal.IsInRole($AdminRole))
{
    Write-Host "This script must be run as an Administrator. Please re-run this script as an Administrator!"
    exit
}

# deactivate sleep and hibernation mode

# Step 1. Disable sleep and hibernation
& powercfg -h off
& powercfg -change -standby-timeout-ac 0
& powercfg -change -standby-timeout-dc 0

# Step 2. Open the window. When the window is closed, execute step 3.
Add-Type -AssemblyName System.Windows.Forms
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Notification'
$form.TopMost = $true
$form.Size = New-Object System.Drawing.Size(350, 100)

$label = New-Object System.Windows.Forms.Label
$label.Text = 'PC is active until this window is open'
$label.AutoSize = $true
$label.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Bold)
$form.Controls.Add($label)

$form.ShowDialog() | Out-Null

# Step 3. Re-enable sleep and hibernation
& powercfg -h on
& powercfg -change -standby-timeout-ac 20
& powercfg -change -standby-timeout-dc 20
