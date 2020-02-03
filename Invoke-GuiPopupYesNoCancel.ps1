function Invoke-GuiPopupYesNoCancel ([string]$MessageBody,[string]$MessageTitle)
{
    Add-Type -AssemblyName PresentationCore,PresentationFramework
    $ButtonType = [System.Windows.MessageBoxButton]::YesNoCancel
    $MessageIcon = [System.Windows.MessageBoxImage]::Question
 
    [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
}

