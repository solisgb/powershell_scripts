# deactivate sleep and hibernation mode

# Step 1. Disable sleep and hibernation
& powercfg -h off
& powercfg -s off

# Step 2. Open the window. When the window is closed, execute step 3.
Add-Type -AssemblyName System.Windows.Forms
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Notification'
$form.TopMost = $true

$label = New-Object System.Windows.Forms.Label
$label.Text = 'PC is active until this window is open'
$label.AutoSize = $true
$label.Font = New-Object System.Drawing.Font("Arial",16,[System.Drawing.FontStyle]::Bold)
$form.Controls.Add($label)

$form.ShowDialog() | Out-Null

# Step 3. Re-enable sleep and hibernation
& powercfg -h on
& powercfg -s on
