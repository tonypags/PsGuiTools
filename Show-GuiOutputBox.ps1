function Show-GuiOutputBox {
    
    <#
    .SYNOPSIS
    Display several lines of text in a pop up window
    .DESCRIPTION
    Displays a pop up window from which a non-technical user can review any number of text values.
    .PARAMETER InputArray
    The string array to display in a pop up window
    .PARAMETER Title
    A title for the pop up window
    .PARAMETER Monospace
    Display text as monospaced (Consolas font)
    #>

    [CmdletBinding()]
    Param
    (
        # The string array to display in a pop up window
        [Parameter(ValueFromPipeline=$true)]
        [string[]]
        $InputArray,

        # A title for the pop up window
        [string]
        $Title = "Display Information",

        # Display text as monospaced (Consolas font)
        [switch]
        $Monospace = $false
    )

    Begin
    {
        # Load assemblies and draw form
        [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
        [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
        $Form = New-Object System.Windows.Forms.Form
        $Form.Size = New-Object System.Drawing.Size(700,600)

        $OutputArray = [System.Collections.ArrayList]@()
    }

    Process {
        
        foreach ($item in $InputArray) {
            [void]$OutputArray.Add($item)
        }

    }

    End {

        $Form.text = $Title

        # Text fields
        $outputBox = New-Object System.Windows.Forms.TextBox
        $outputBox.Location = New-Object System.Drawing.Size(10,10) #location of the text box (px) in relation to the primary window's edges (length, height)
        $outputBox.Size = New-Object System.Drawing.Size(665,490) #the size in px of the text box (length, height)
        $outputBox.MultiLine = $True #declaring the text box as multi-line
        $outputBox.ScrollBars = "Vertical","Horizontal" #adding scroll bars if required
        $outputBox.WordWrap = $False

        # Buttons
        $Button = New-Object System.Windows.Forms.Button #create the button
        $Button.Location = New-Object System.Drawing.Size(480,518) #location of the button (px) in relation to the primary window's edges (length, height)
        $Button.Size = New-Object System.Drawing.Size(75,25) #the size in px of the button (length, height)
        $Button.Text = "Close" #labeling the button
        $Button.Add_Click({$form.Close()}) #the action triggered by the button
        $Form.Controls.Add($Button) #activating the button inside the primary window

        # Text Values
        if($Monospace) {
            $Form.Font = New-Object System.Drawing.Font("Consolas",10)
        }
        $outputBox.Text = [System.Collections.ArrayList]@()
        foreach ($item in $OutputArray) {
            $outputBox.Text += "$($Item)`r`n"
        }
        $Form.Controls.Add($outputBox) #activating the text box inside the primary window

        # Show form
        $Form.TopMost = $true
        $Form.Add_Shown({$Form.Activate()})
        [void] $Form.ShowDialog()

    }

}
