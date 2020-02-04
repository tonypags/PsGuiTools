Function Show-GuiFolderPicker {
    <#
    .SYNOPSIS
    Returns a folder object from a GUI pop up window.
    .DESCRIPTION
    Displays a folder picker window for the user, allowing non-technical users to leverage an automated routine.
    .PARAMETER Title
    Message for the pop up window title bar
    .PARAMETER InitialDirectory
    Default path location of the picker window.
    .PARAMETER outString
    Limit the output to a string value
    .EXAMPLE
    $SaveFolder = Show-GuiFolderPicker
    .NOTES
    InitialDirectory ENUM: https://msdn.microsoft.com/en-us/library/system.environment.specialfolder(v=vs.110).aspx
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        $Title = 'Choose a Folder',

        [Parameter()]
        [ValidateSet('MyComputer','Recent','MyDocuments','Favorites','Desktop','Templates')]
        $InitialDirectory = 'Recent'

    )
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
    $OpenFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $OpenFolderDialog.RootFolder = $InitialDirectory
    $OpenFolderDialog.Description = $Title 
    $OpenFolderDialog.ShowDialog() | Out-Null
    [string]$FullName = $OpenFolderDialog.SelectedPath
    if ($outString) {$FullName} else {Get-Item $FullName}
}

