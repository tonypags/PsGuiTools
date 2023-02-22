function Show-GuiMultiInputBox {

    <#
    .SYNOPSIS
    Paste in unformatted text to be stored as a string array
    .DESCRIPTION
    Prompts the user with a multi-line input box and returns the text they enter, or null if they cancelled the prompt.
    .PARAMETER Title
    A title for the pop up window
    .PARAMETER Message
    Message or description shown before the text input field
    .PARAMETER DefaultText
    The initial value of the user text input field
    .EXAMPLE
    $userText = Show-GuiMultiInputBox "Get User's Input" "Input some text please:"     
    .EXAMPLE
    # Setup the default multi-line address to fill the input box with.
    $defaultAddress = @'
    John Doe
    123 St.
    Some Town, SK, Canada
    A1B 2C3
    '@
     
    $address = Show-GuiMultiInputBox "Address Form" "Please enter your full address, including name, street, city, and postal code:" $defaultAddress
    if ($address -eq $null)
    {
        Write-Error "You pressed the Cancel button on the multi-line input box."
    }
     
    Prompts the user for their address and stores it in a variable, pre-filling the input box with a default multi-line address.
    If the user pressed the Cancel button an error is written to the console.
    #>

    param (
        
        [Parameter(Position=0)]
        # A title for the pop up window
        [string]
        $Title,
        
        # Message or description shown before the text input field
        [Parameter(Position=1)]
        [string]
        $Message,
        
        [Parameter(Position=2)]
        # The initial value of the user text input field
        [string[]]
        $DefaultText

    )

    Begin {

        Add-Type -AssemblyName System.Drawing
        Add-Type -AssemblyName System.Windows.Forms

    }
     
    Process {}
    
    End {
    
        # Create the Label
        $label = New-Object System.Windows.Forms.Label
        $label.Location = New-Object System.Drawing.Size(10,10) 
        $label.Size = New-Object System.Drawing.Size(280,20)
        $label.AutoSize = $true
        $label.Text = $Message
        
        # Create the TextBox used to capture the user's text.
        $textBox = New-Object System.Windows.Forms.TextBox 
        $textBox.Location = New-Object System.Drawing.Size(10,40) 
        $textBox.Size = New-Object System.Drawing.Size(575,200)
        $textBox.AcceptsReturn = $true
        $textBox.AcceptsTab = $false
        $textBox.Multiline = $true
        $textBox.ScrollBars = 'Both'
        $textBox.Text = $DefaultText
        
        # Create the OK button.
        $okButton = New-Object System.Windows.Forms.Button
        $okButton.Location = New-Object System.Drawing.Size(510,250)
        $okButton.Size = New-Object System.Drawing.Size(75,25)
        $okButton.Text = "OK"
        [void]$okButton.Add_Click({ $form.Tag = $textBox.Text; $form.Close() })
        
        # Create the Cancel button.
        $cancelButton = New-Object System.Windows.Forms.Button
        $cancelButton.Location = New-Object System.Drawing.Size(415,250)
        $cancelButton.Size = New-Object System.Drawing.Size(75,25)
        $cancelButton.Text = "Cancel"
        [void]$cancelButton.Add_Click({ $form.Tag = $null; $form.Close() })
        
        # Create the form.
        $form = New-Object System.Windows.Forms.Form 
        $form.Text = $WindowTitle
        $form.Size = New-Object System.Drawing.Size(615,340)
        $form.FormBorderStyle = 'FixedSingle'
        $form.StartPosition = "CenterScreen"
        $form.AutoSizeMode = 'GrowAndShrink'
        $form.Topmost = $True
        $form.AcceptButton = $okButton
        $form.CancelButton = $cancelButton
        $form.ShowInTaskbar = $true
        
        # Add all of the controls to the form.
        [void]$form.Controls.Add($label)
        [void]$form.Controls.Add($textBox)
        [void]$form.Controls.Add($okButton)
        [void]$form.Controls.Add($cancelButton)
        
        # Initialize and show the form.
        [void]$form.Add_Shown({$form.Activate()})
        $form.ShowDialog() > $null   # Trash the text of the button that was clicked.
        
        # Re-Format & Return the text that the user entered.
        $form.Tag -split "`n" | ForEach-Object {

            if ($_.length -gt 0)
            { $_.trimend() }
        
        }
    
    }

}

