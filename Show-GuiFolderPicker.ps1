Function Show-GuiFolderPicker {
    
    <#
    .SYNOPSIS
    Returns a folder object from a GUI pop up window.
    .DESCRIPTION
    Displays a folder picker window for the user, allowing non-technical users to leverage an automated routine.
    .PARAMETER Title
    A title for the pop up window
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
        
        # A title for the pop up window
        [Parameter()]
        $Title = 'Choose a Folder',

        # Default path location of the picker window.
        [Parameter()]
        [ValidateSet('MyComputer','Recent','MyDocuments','Favorites','Desktop','Templates')]
        $InitialDirectory = 'Recent',

        # Limit the output to a string value
        [Parameter()]
        [switch]
        $outString
    )

    [void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
    $OpenFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $OpenFolderDialog.RootFolder = $InitialDirectory
    $OpenFolderDialog.Description = $Title 
    $OpenFolderDialog.ShowDialog() | Out-Null
    [string]$FullName = $OpenFolderDialog.SelectedPath
    if ($outString) {$FullName} else {Get-Item $FullName}
}

