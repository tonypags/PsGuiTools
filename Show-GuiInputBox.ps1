function Show-GuiInputBox {

    <#
    .SYNOPSIS
    Text input dialog window
    .DESCRIPTION
    Displays a popup window with which a non-technical user can enter a string value for an automated routine
    .PARAMETER Title
    A title for the pop up window
    .PARAMETER Message
    Message or description shown before the text input field
    .PARAMETER DefaultText
    The initial value of the user text input field
    #>
    
    param (
        
        # A title for the pop up window
        [Parameter(Position=0)]
        [string]
        $Title = "Enter Text",
        
        # Message or Description for list of items
        [Parameter(Position=1)]
        [string]
        $Message = "Please enter a value here:",
        
        # The initial value of the user text input field
        [Parameter()]
        [string]
        $DefaultText

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
        [Microsoft.VisualBasic.Interaction]::InputBox($Message, $Title, $DefaultText)
    }

}

