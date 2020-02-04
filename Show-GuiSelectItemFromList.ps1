function Show-GuiSelectItemFromList {
    <#
    .SYNOPSIS
    Displays a list from which a user can choose.
    .DESCRIPTION
    Displays a pop up window containing a given list of items, allowing non-technical users to leverage an automated routine.
    .PARAMETER InputArray
    Array of strings to display for the user to pick from
    .PARAMETER Title
    Message for the pop up window title bar
    .PARAMETER Message
    Message or Description for list of items
    .PARAMETER Width
    Width of popup window in pixels
    .PARAMETER Height
    Height of popup window in pixels
    .EXAMPLE
    (Get-Process).Name | Show-GuiSelectItemFromList | Stop-Process -WhatIf
    #>
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        # Array of strings to display for the user to pick from
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [string[]]
        $InputArray,

        # Message for the pop up window title bar
        [string]
        $Title='Select an Item',

        # Message or Description for list of items
        [string]
        $Message='Select from the List of Items:',

        # Width of popup window in pixels
        [int]
        $Width=600,

        # Height of popup window in pixels
        [int]
        $Height=300

    )
   
    Begin {

        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing

        $SelectionArray = [System.Collections.ArrayList]@()

    }

    Process {

        Foreach ($item in $InputArray) {
            
            [void] $SelectionArray.Add($item)
        
        }
    
    }

    End {
        
        $form = New-Object System.Windows.Forms.Form 
        $form.Text = $Title
        $form.Size = New-Object System.Drawing.Size(($Width),($Height)) # 100% x 100%  
        $form.StartPosition = "CenterScreen"

        $OKButton = New-Object System.Windows.Forms.Button
        $OKButton.Location = New-Object System.Drawing.Point(([math]::round(($Width*0.25),0)),([math]::round(($Height*0.6),0))) # 25% x 60%
        $OKButton.Size = New-Object System.Drawing.Size(([math]::round(($Width*0.25),0)),([math]::round(($Height*0.115),0)))    # 25% x 11.5%
        $OKButton.Text = "OK"
        $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.AcceptButton = $OKButton
        $form.Controls.Add($OKButton)

        $CancelButton = New-Object System.Windows.Forms.Button
        $CancelButton.Location = New-Object System.Drawing.Point(([math]::round(($Width*0.5),0)),([math]::round(($Height*0.6),0))) # 50% x 60%
        $CancelButton.Size = New-Object System.Drawing.Size(([math]::round(($Width*0.25),0)),([math]::round(($Height*0.115),0)))   # 25% x 11.5%
        $CancelButton.Text = "Cancel"
        $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $form.CancelButton = $CancelButton
        $form.Controls.Add($CancelButton)

        $label = New-Object System.Windows.Forms.Label
        $label.Location = New-Object System.Drawing.Point(([math]::round(($Width*0.0333333),0)),([math]::round(($Height*0.1),0)))  # 3.33% x 10%
        $label.Size = New-Object System.Drawing.Size(([math]::round(($Width*0.933333333),0)),([math]::round(($Height*0.1),0)))     # 93.33% x 10%
        $label.Text = $Message
        $form.Controls.Add($label) 

        $listBox = New-Object System.Windows.Forms.ListBox 
        $listBox.Location = New-Object System.Drawing.Point(([math]::round(($Width*0.033333333),0)),([math]::round(($Height*0.2),0)))  # 3.33% x 20%
        $listBox.Size = New-Object System.Drawing.Size(([math]::round(($Width*0.866666667),0)),([math]::round(($Height*0.1),0)))       # 86.67% x 10%
        $listBox.Height = ([math]::round(($Height*0.4),0))  # 40%

        Foreach ($A in $SelectionArray){
            [void] $listBox.Items.Add("$A")
        }

        $form.Controls.Add($listBox) 
        $form.Topmost = $True
        $result = $form.ShowDialog()

        if ($result -eq [System.Windows.Forms.DialogResult]::OK) {

            $listBox.SelectedItem

        }

    }

}
