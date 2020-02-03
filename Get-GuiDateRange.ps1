function Get-GuiDateRange
{
    [OutputType([datetime[]])] 
    param ([switch]$Extremes)

    [datetime]$StartDate = Invoke-GuiDatePicker -title 'Enter Start Date'
    [datetime]$EndDate  = Invoke-GuiDatePicker -title 'Enter End Date'
    
    $DateArray = @()
    for 
    (
        $i = $StartDate
        $i -le $EndDate
        $i = $i.AddDays(1)
    )
    { $DateArray += [datetime]$i.ToShortDateString() }

    if($Extremes){
        $FullArray = $DateArray | sort
        $DateArray = @()
        $DateArray += $FullArray[0]
        $DateArray += $FullArray[-1]
        $DateArray =  $DateArray | sort
    }

    Write-Output $DateArray
}

