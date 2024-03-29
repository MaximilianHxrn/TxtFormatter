﻿$startFolder = $args[0]

Function Get-Folder($initialDirectory) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    Set-Location "C:\Repository\TxtFormatter"
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select a folder"
    $foldername.rootfolder = "MyComputer"
    $foldername.SelectedPath = $startFolder
    if ($foldername.ShowDialog() -eq "OK") {
        $folder += $foldername.SelectedPath
        .\Formatter.exe '"' $folder '"'
    }
    else {
        .\Format-Repository.ps1
    }
}

Function Get-File($initialDirectory) { 
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    Set-Location "C:\Repository\TxtFormatter"
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $startFolder
    $OpenFileDialog.filter = "AL Files (*.al)|*.al"
    if ($OpenFileDialog.ShowDialog() -eq "OK") {
        $folder += $OpenFileDialog.FileName
        .\Formatter.exe '"' $folder '"'
    }
    else {
         .\Format-Repository.ps1
    }
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Format Repository'
$form.Size = New-Object System.Drawing.Size(300, 125)
$form.StartPosition = 'CenterScreen'
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(75, 50)
$OKButton.Size = New-Object System.Drawing.Size(75, 23)
$OKButton.Text = 'Folder'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::Yes
$form.Controls.Add($OKButton)
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(150, 50)
$CancelButton.Size = New-Object System.Drawing.Size(75, 23)
$CancelButton.Text = 'File'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Ok
$form.Controls.Add($UnsafeMode)
$form.Controls.Add($CancelButton)
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10, 20)
$label.Size = New-Object System.Drawing.Size(280, 50)
$label.Text = "      Choose how you want to format your repository:"
$form.Controls.Add($label)
$form.Topmost = $true
$form.KeyPreview = $true #This is the important part
$form.Add_KeyDown{
    param ( 
        [Parameter(Mandatory)][Object]$sender,
        [Parameter(Mandatory)][System.Windows.Forms.KeyEventArgs]$e
    )
    if($e.KeyCode -eq "Escape") {
        [System.Windows.Forms.Application]::DoEvents()
		$form.Close()
    }
}
$form.FormBorderStyle = 'FixedDialog';
$form.MaximizeBox = $false;
$form.MinimizeBox = $false;
$result = $form.ShowDialog()
 
if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
    Get-Folder
}
if ($result -eq [System.Windows.Forms.DialogResult]::Ok) {
    Get-File
}