Function Get-Folder($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select a folder"
    $foldername.rootfolder = "MyComputer"
    $foldername.SelectedPath = $initialDirectory

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
		cd "Z:\Transfer\sit.mh\TxtFormatter"
		.\Formatter.exe $folder
    }

}

Function Get-File($initialDirectory)
{ 
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "AL files (*.al)|*.al"
    if($OpenFileDialog.ShowDialog() -eq "OK")
    {
        $folder += $OpenFileDialog.FileName
		cd "Z:\Transfer\sit.mh\TxtFormatter"
        .\Formatter.exe $folder
    }
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Format Repository'
$form.Size = New-Object System.Drawing.Size(300,120)
$form.StartPosition = 'CenterScreen'
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(75,50)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'Folder'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(150,50)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = 'File'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,50)
$label.Text = "      Choose how you want to format your repository"
$form.Controls.Add($label)
$form.Topmost = $true
$result = $form.ShowDialog()
 
if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    Get-Folder
}
if ($result -eq [System.Windows.Forms.DialogResult]::Cancel)
{
    Get-File
}