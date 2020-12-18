param
(
    [string] $workspaceFolder
)

if ([string]::IsNullOrEmpty($workspaceFolder))
{
    $workspaceFolder = "`"" + (Get-Item -Path ".\" -Verbose).FullName + "`""
}
else
{
    Write-Host ''
    Write-Host 'Please ensure when calling sit-format via GIT Bash that your directory should look like:'
    Write-Host ''
    Write-Host '< ''"Your\Path\To\File"'' >'
    Write-Host ''
    Write-Host '______________________________'
    Write-Host ''
}
cd '\\sitsrv061\WinFrame\Transfer\cir.al\StandaloneDevTools\TxtFormatter'
.\Formatter.exe $workspaceFolder