function Invoke-GuiMultiLineOutputDialog
{
    [CmdletBinding()]
    Param
    (
        # The string[] data to display in a text window
        [Parameter(ValueFromPipeline=$true)]
        [string[]]
        $InputArray,

        # Title bar text
        [string]
        $Title = "Display Information",

        # Display Font as Consolas (monospaced)
        [switch]
        $Consolas = $false
    )

    Begin
    {
        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
        $Form = New-Object System.Windows.Forms.Form
        $Form.Size = New-Object System.Drawing.Size(700,600)
        $Form.text = $Title

        ############################################## Start text fields

        $outputBox = New-Object System.Windows.Forms.TextBox #creating the text box
        $outputBox.Location = New-Object System.Drawing.Size(10,10) #location of the text box (px) in relation to the primary window's edges (length, height)
        $outputBox.Size = New-Object System.Drawing.Size(665,490) #the size in px of the text box (length, height)
        $outputBox.MultiLine = $True #declaring the text box as multi-line
        $outputBox.ScrollBars = "Vertical","Horizontal" #adding scroll bars if required
        $outputBox.WordWrap = $False

        ############################################## end text fields

        ############################################## Start buttons

        $Button = New-Object System.Windows.Forms.Button #create the button
        $Button.Location = New-Object System.Drawing.Size(480,518) #location of the button (px) in relation to the primary window's edges (length, height)
        $Button.Size = New-Object System.Drawing.Size(75,25) #the size in px of the button (length, height)
        $Button.Text = "Close" #labeling the button
        $Button.Add_Click({ $form.Close() }) #the action triggered by the button
        $Form.Controls.Add($Button) #activating the button inside the primary window

        ############################################## end buttons

    }
    Process
    {
    }
    End
    {
        ############################################## Start text fields
        if($Consolas){$Form.Font = New-Object System.Drawing.Font("Consolas",10)}
        [string[]]$outputBox.Text=@(); foreach ($item in $InputArray) {$outputBox.Text += "$($Item)`r`n"} 
        $Form.Controls.Add($outputBox) #activating the text box inside the primary window
        ############################################## end text fields

        $Form.TopMost = $true
        $Form.Add_Shown({$Form.Activate()})
        [void] $Form.ShowDialog()
    }
}