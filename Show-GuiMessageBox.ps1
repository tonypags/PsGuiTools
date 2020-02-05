function Show-GuiMessageBox {

    <#
    .SYNOPSIS
    Various window pop up configurations
    .DESCRIPTION
    Displays a popup window with which a non-technical user can interact, with options such as OK, Cancel, YesNo, Error, etc
    .PARAMETER Title
    A title for the pop up window
    .PARAMETER Message
    Message or Description for list of items
    .PARAMETER Button
    Select from available button types
    .PARAMETER Icon
    Select from available message icons
    .NOTES
    Icon ENUM: https://docs.microsoft.com/en-us/dotnet/api/system.windows.messageboximage?view=netframework-4.8
    Button ENUM: https://docs.microsoft.com/en-us/dotnet/api/system.windows.messageboxbutton?view=netframework-4.8
    #>

    [CmdletBinding()]
    
    param (

        # A title for the pop up window
        [Parameter(Position=0)]
        [string]
        $Title,

        # Message or Description for list of items
        [Parameter(Position=1)]
        [string]
        $Message,

        # Select from available button types
        [Parameter()]
        [ValidateSet('OK','OKCancel','YesNo','YesNoCancel')]
        $Button = 'OK',

        # Select from available message icons
        [Parameter()]
        [ValidateSet('Asterisk','Error','Exclamation','Hand','Information','None','Question','Warning','Stop')]
        $Icon = 'Asterisk'

    )

    Begin {

        Add-Type -AssemblyName PresentationCore,PresentationFramework

    }

    Process {}

    End {
        
        $ButtonType = [System.Windows.MessageBoxButton]::$Button
        $MessageIcon = [System.Windows.MessageBoxImage]::$Icon

        [System.Windows.MessageBox]::Show($Message,$Title,$ButtonType,$MessageIcon)

    } 

}
