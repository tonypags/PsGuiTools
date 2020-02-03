Function Invoke-GuiFilePicker 
{   
    param(
        [string]$Title = "Select File(s)",
        [string]$InitialDirectory=
            "$($env:USERPROFILE)\Downloads",
        [string]$Extension, 
        [switch]$Single=$false,
        [switch]$outString=$false
    )

    if(Test-Path $InitialDirectory){

        if($Extension -match '\.|\*'){
            $Extension = $Extension -replace '\.' -replace '\*'
        }

        $Filter = switch ($Extension)
        {
            'txt'  {"Text Files (*.txt) | *.txt" ; break }
            'csv'  {"CSV files (*.csv) | *.csv" ; break }
            'xml'  {"XML files (*.xml) | *.xml" ; break }
            'pdf'  {"PDF files (*.pdf) | *.pdf" ; break }
            'xlsx' {"Excel files (*.xlsx) | *.xlsx" ; break }
            'docx' {"Word files (*.docx) | *.docx" ; break }
<#
            # Catch-all (attempt)
            "$($Extension)" 
                   {"$($Extension.ToUpper()) files (*.$(
                   $Extension.ToLower())) | *.$(
                   $Extension.ToLower())" ; break }
#>
            Default {"All Files (*.*) | *.*"}
        }

        [void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
        
        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog

        $OpenFileDialog.filter = $Filter
        $OpenFileDialog.InitialDirectory = $InitialDirectory
        $OpenFileDialog.RestoreDirectory = $true
        $OpenFileDialog.Title = $Title
        $OpenFileDialog.Multiselect = (!$Single)
        #$OpenFileDialog.Topmost = $True  # not supported? causes error
        $OpenFileDialog.CheckFileExists = (!$outString)
        $OpenFileDialog.ShowDialog() | Out-Null

        [string[]]$FullName = $OpenFileDialog.Filenames

        Write-Output (%{if ($outString){$FullName}else{Get-Item $FullName}})
    }else{
        Invoke-GuiPopupWarningOK `
            -MessageTitle "Path not Found!" `
            -MessageBody "The path $($InitialDirectory) cannot be found. "
    }
}


