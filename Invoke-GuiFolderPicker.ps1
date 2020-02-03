Function Invoke-GuiFolderPicker ($Title = 'Choose a folder')
{   
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
    $OpenFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $OpenFolderDialog.RootFolder = 'MyComputer'   # https://msdn.microsoft.com/en-us/library/system.environment.specialfolder(v=vs.110).aspx
    $OpenFolderDialog.Description = $Title 
    $OpenFolderDialog.ShowDialog() | Out-Null
    [string[]]$FullName = $OpenFolderDialog.SelectedPath
    Write-Output (Get-Item $FullName)
}

