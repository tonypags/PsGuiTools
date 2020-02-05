function Show-GuiInputBox {

    <#
    .SYNOPSIS
    Text input dialog window
    .DESCRIPTION
    Displays a popup window with which a non-technical user can enter a string value for an automated routine
    .PARAMETER Title
    Message for the pop up window title bar
    .PARAMETER Message
    Message or Description for list of items
    #>
    
    param (
        
        # Message for the pop up window title bar    
        [Parameter(Position=0)]
        [string]
        $Title = "Enter Text",
        
        # Message or Description for list of items
        [Parameter(Position=1)]
        [string]
        $Message = "Please enter a value here:",
        
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

