function Show-GuiInputBox {

    <#
    .SYNOPSIS
    Various window pop up configurations
    .DESCRIPTION
    Displays a popup window with which a non-technical user can interact, with options such as OK, Cancel, YesNo, Error, etc
    .PARAMETER Title
    Message for the pop up window title bar
    .PARAMETER Message
    Message or Description for list of items
    #>
    
    param (
        
        [Parameter(Position=0)]
        [string]
        $Title = "Input Text",
        
        [Parameter(Position=1)]
        [string]
        $Message = "Enter a value:",
        
        [Parameter()]
        [string]
        $Default

    )

    Begin {

        Try {
            Add-Type -AssemblyName Microsoft.VisualBasic -ea Stop
        } Catch {
            throw 'Unable to load VB assembly.'
        }

    }

    Process {}

    End {
        [Microsoft.VisualBasic.Interaction]::InputBox($Message, $Title, $Default)
    }

}

