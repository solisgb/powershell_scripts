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

# Step 1. Deactivate sleep and hibernation mode
# Turn off the hibernation feature
& powercfg -h off
# Set the sleep timeout to 0 minutes (AC, battery); computer will never go into sleep mode.
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
$label.Font = New-Object System.Drawing.Font("Arial",11,[System.Drawing.FontStyle]::Bold)
$form.Controls.Add($label)

$form.ShowDialog() | Out-Null

# Step 3. Re-enable sleep and hibernation
#sminutes
$time_standby_ac = 20
$time_standby_dc = 4

& powercfg -h on
& powercfg -change -standby-timeout-ac $time_standby_ac
& powercfg -change -standby-timeout-dc $time_standby_dc

Write-Host "`nComputer standby timeouts (minutes)"
Write-Host "`Plugged in: $time_standby_ac"
Write-Host "On battery: $time_standby_dc`n"

