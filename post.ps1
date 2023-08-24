Add-Type -AssemblyName System.Windows.Forms

# Create a form
$form = New-Object System.Windows.Forms.Form
$form.Text = "PowerShell GUI"
$form.Size = New-Object System.Drawing.Size(800, 600)

# Create a ListView
$listView = New-Object System.Windows.Forms.ListView
$listView.Location = New-Object System.Drawing.Point(10, 60)
$listView.Width = 780
$listView.Height = 200
$listView.View = [System.Windows.Forms.View]::Details
$listView.FullRowSelect = $true
$listView.CheckBoxes = $true
$listView.Columns.Add("Name", 150)
$listView.Columns.Add("Package Full Name", 350)
$form.Controls.Add($listView)

# Create a "Show Packages" button
$showPackagesButton = New-Object System.Windows.Forms.Button
$showPackagesButton.Text = "Show Packages"
$showPackagesButton.Width = 130
$showPackagesButton.Location = New-Object System.Drawing.Point(10, 10)
$showPackagesButton.Add_Click({
    $packages = Get-AppxPackage | Select-Object Name, PackageFullName
    $listView.Items.Clear()
    foreach ($package in $packages) {
        $item = New-Object System.Windows.Forms.ListViewItem($package.Name)
        $item.SubItems.Add($package.PackageFullName)
        $listView.Items.Add($item)
    }
})
$form.Controls.Add($showPackagesButton)

# Create an "Export Selected" button
$exportButton = New-Object System.Windows.Forms.Button
$exportButton.Text = "Export Selected"
$exportButton.Width = 130
$exportButton.Location = New-Object System.Drawing.Point(150, 10)
$exportButton.Add_Click({
    $selectedPackages = $listView.CheckedItems | ForEach-Object { $_.SubItems[1].Text }
    $filePath = Join-Path (Get-Location) "list.txt"
    $selectedPackages | Out-File -FilePath $filePath
    [System.Windows.Forms.MessageBox]::Show("Selected package names exported to $filePath", "Export Complete")
})
$form.Controls.Add($exportButton)

# Create a "Check for list.txt" button
$checkButton = New-Object System.Windows.Forms.Button
$checkButton.Text = "Check for list.txt"
$checkButton.Width = 130
$checkButton.Location = New-Object System.Drawing.Point(290, 10)
$checkButton.Add_Click({
    $filePath = Join-Path (Get-Location) "list.txt"
    if (Test-Path $filePath) {
        [System.Windows.Forms.MessageBox]::Show("list.txt exists in the same location.", "File Found")
    } else {
        [System.Windows.Forms.MessageBox]::Show("list.txt not found in the same location.", "File Not Found")
    }
})
$form.Controls.Add($checkButton)

# Create a "Start Removing Packages" button
$removeButton = New-Object System.Windows.Forms.Button
$removeButton.Text = "Start Removing Packages"
$removeButton.Width = 130
$removeButton.Location = New-Object System.Drawing.Point(430, 10)
$removeButton.Add_Click({
    $lines = Get-Content -Path 'list.txt'
    $notFound = @()

    foreach ($line in $lines) {
        $line = $line.Trim()

        if (-not [string]::IsNullOrWhiteSpace($line)) {
            $package = Get-AppxPackage | Where-Object { $_.Name -eq $line -or $_.PackageFullName -eq $line }

            if ($package) {
                try {
                    $package | Remove-AppxPackage -ErrorAction Stop
                } 
                catch {
                    Write-Host "Error while trying to uninstall $($line): $_"
                    $notFound += $line
                }
            } 
            else {
                $notFound += $line
            }
        }
    }

    if ($notFound.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("All packages removed successfully.", "Packages Removed")
    } else {
        [System.Windows.Forms.MessageBox]::Show("Packages removed with errors. See console for details.", "Packages Removed with Errors")
    }
})
$form.Controls.Add($removeButton)

# Create a "Start winutil" button
$winutilButton = New-Object System.Windows.Forms.Button
$winutilButton.Text = "Start winutil"
$winutilButton.Width = 130
$winutilButton.Location = New-Object System.Drawing.Point(570, 10)
$winutilButton.Add_Click({
    Invoke-Expression (irm https://christitus.com/win)
})
$form.Controls.Add($winutilButton)

# Show the form
$form.ShowDialog()
