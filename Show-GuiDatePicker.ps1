function Show-GuiDatePicker {

    <#
    .SYNOPSIS
    Display a Month Calendar in a pop up window
    .DESCRIPTION
    Displays a pop up window from which a non-technical user can choose a date during an automated routine
    .PARAMETER Title
    A title for the pop up window
    #>

    param  (
        # A title for the pop up window
        [Parameter()]
        [string]    
        $Title = 'Choose a Date'
    )

    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
     
    $global:chosendate = $null
    $form = New-Object Windows.Forms.Form
    $form.Size = New-Object Drawing.Size(233,190)
    $form.StartPosition = "CenterScreen"
    $form.KeyPreview = $true
    $form.FormBorderStyle = "FixedSingle"
    $form.Text = $title
    $calendar = New-Object System.Windows.Forms.MonthCalendar
    $calendar.ShowTodayCircle = $false
    $calendar.MaxSelectionCount = 1
    $form.Controls.Add($calendar)
    $form.TopMost = $true
     
    $form.add_KeyDown({
        if($_.KeyCode -eq "Escape") {
            $global:chosendate = $false
            $form.Close()
        }
    })
     
    $calendar.add_DateSelected({
        $global:chosendate = $calendar.SelectionStart
        $form.Close()
    })
     
    [void]$form.add_Shown($form.Activate())
    [void]$form.ShowDialog()

    Write-Output (Get-Date $global:chosendate)
}
 
