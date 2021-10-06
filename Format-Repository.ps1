Function Get-Folder($initialDirectory) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select a folder"
    $foldername.rootfolder = "MyComputer"
    $foldername.SelectedPath = $initialDirectory
    if ($foldername.ShowDialog() -eq "OK") {
        $folder += $foldername.SelectedPath
        Set-Location "\\sitsrv061\WinFrame\Transfer\cir.al\StandaloneDevTools\TxtFormatter"
        .\Formatter.exe $folder $UnsafeMode.Checked
    }
    else {
        .\Format-Repository.ps1
    }
}

Function CheckUnsafe() {
    if ($UnsafeMode.Checked) {
        $msg = "This mode may lead to false correction of your code. Use with Caution!"
        [System.Windows.Forms.MessageBox]::Show($msg,"Information",[System.Windows.Forms.MessageBoxButtons]::OK)
    }
}

Function Get-File($initialDirectory) { 
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "AL files (*.al)|*.al"
    if ($OpenFileDialog.ShowDialog() -eq "OK") {
        $folder += $OpenFileDialog.FileName
		Set-Location "\\sitsrv061\WinFrame\Transfer\cir.al\StandaloneDevTools\TxtFormatter"
        .\Formatter.exe $folder $UnsafeMode.Checked
    }
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Format Repository'
$form.Size = New-Object System.Drawing.Size(300, 150)
$form.StartPosition = 'CenterScreen'
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(75, 50)
$OKButton.Size = New-Object System.Drawing.Size(75, 23)
$OKButton.Text = 'Folder'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::Yes
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(150, 50)
$CancelButton.Size = New-Object System.Drawing.Size(75, 23)
$CancelButton.Text = 'File'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::No
$UnsafeMode = New-Object System.Windows.Forms.Checkbox 
$UnsafeMode.Location = New-Object System.Drawing.Size(30, 85) 
$UnsafeMode.Size = New-Object System.Drawing.Size(500, 20)
$UnsafeMode.Text = "    Enable Unsafe Mode (case insensitive)"
$UnsafeMode.TabIndex = 4
$form.Controls.Add($UnsafeMode)
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10, 20)
$label.Size = New-Object System.Drawing.Size(280, 50)
$label.Text = "      Choose how you want to format your repository"
$form.Controls.Add($label)
$form.Topmost = $true
$form.KeyPreview = $true #This is the important part
$form.Add_KeyDown{
    param ( 
        [Parameter(Mandatory)][Object]$sender,
        [Parameter(Mandatory)][System.Windows.Forms.KeyEventArgs]$e
    )
    if($e.KeyCode -eq "Escape"){
        $Form.close()
    }
}
$result = $form.ShowDialog()
 
if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
    CheckUnsafe
    Get-Folder
}
if ($result -eq [System.Windows.Forms.DialogResult]::No) {
    CheckUnsafe
    Get-File
}