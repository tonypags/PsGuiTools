function Invoke-GuiTextInputDialog ([string]$Message="Enter some value:",[string]$Title="Input Text",[string]$Default=$null)
{
    Add-Type -AssemblyName Microsoft.VisualBasic
    $inputText = [Microsoft.VisualBasic.Interaction]::InputBox($Message, $Title, $Default)
    Write-Output $inputText
}

