function Show-GuiFilePicker {

    <#
    .SYNOPSIS
    Returns file objects from a GUI pop up window.
    .DESCRIPTION
    Displays a file picker window for the user, allowing non-technical users to leverage an automated routine.
    .PARAMETER Title
    A title for the pop up window
    .PARAMETER InitialDirectory
    Default path location of the picker window
    .PARAMETER Extension
    Filter the picker window by file type, supported: txt, csv, xml, pdf, xlsx, docx
    .PARAMETER Single
    Limit the picker window to a single selection
    .PARAMETER outString
    Limit the output to a string value(s)
    .EXAMPLE
    Show-GuiFilePicker -Title 'Select a File' -Single
    #>

    [CmdletBinding()]
    param (
        
        # A title for the pop up window
        [Parameter()]
        [string]
        $Title = "Select File(s)",

        # Default path location of the picker window
        [Parameter()]
        [string]
        $InitialDirectory = "$($env:USERPROFILE)\Downloads",

        # Filter the picker window by file type, supported: txt, csv, xml, pdf, xlsx, docx
        [Parameter()]
        [string]
        $Extension, 

        # Limit the picker window to a single selection
        [Parameter()]
        [switch]
        $Single,

        # Limit the output to a string value(s)
        [Parameter()]
        [switch]
        $outString
        
    )

    if (Test-Path $InitialDirectory) {

        if($Extension -match '\.|\*') {
            $Extension = $Extension -replace '\.' -replace '\*'
        }

        
        $Filter = switch ($Extension) {
        
            'txt'  {"Text Files (*.txt) | *.txt" ; break }
            'csv'  {"CSV files (*.csv) | *.csv" ; break }
            'xml'  {"XML files (*.xml) | *.xml" ; break }
            'pdf'  {"PDF files (*.pdf) | *.pdf" ; break }
            'xlsx' {"Excel files (*.xlsx) | *.xlsx" ; break }
            'docx' {"Word files (*.docx) | *.docx" ; break }

            Default {"All Files (*.*) | *.*"}
        }


        [void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")        
        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog

        $OpenFileDialog.filter = $Filter
        $OpenFileDialog.InitialDirectory = $InitialDirectory
        $OpenFileDialog.RestoreDirectory = $true
        $OpenFileDialog.Title = $Title
        $OpenFileDialog.Multiselect = (!$Single)
        $OpenFileDialog.CheckFileExists = (!$outString)
        $OpenFileDialog.ShowDialog() | Out-Null

        [string[]]$FullName = $OpenFileDialog.Filenames

        if ($outString) {$FullName} else {Get-Item $FullName}

    }else{
    
        $msgSplat = @{
            MessageTitle = "Path not Found!"
            MessageBody = "The path $($InitialDirectory) cannot be found."
            Button = 'OK'
            Icon = 'Error'
        }
        Show-MessageBox @msgSplat
            
    }
}


