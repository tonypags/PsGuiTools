#Requires -Modules PsGuiTools
#Requires -RunAsAdministrator

$Parent = Join-Path (Split-Path $PSScriptRoot -Parent) 'usr'
$Path = Join-Path $Parent 'myWindowApps-ProcessName.txt'

$currNames = Get-Content $Path

$ignoreNames = @(
    'ApplicationFrameHost'
    'explorer'
    'SystemSettings'
    'WindowsInternal.ComposableShell.Experiences.TextInput.InputApp'
)

$Names = Get-Process -IncludeUserName |
    Where-Object {
        $_.UserName -like "*$($env:USERNAME)" -and
        $_.Name -notin $currNames -and
        # [intptr], not [int]
        $_.MainWindowHandle -ne 0
    } |
    Select-Object -ExpandProperty Name -Unique

$currNames + $Names | Out-File -FilePath $Path

$msg = "Please review the file contents. Keep only process names to track windows"
Write-Verbose $msg -Verbose
Write-Verbose $Path -Verbose
