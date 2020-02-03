function Invoke-GuiPopupErrorOkCancel ([string]$MessageBody,[string]$MessageTitle)
{
    Add-Type -AssemblyName PresentationCore,PresentationFramework
    $Button = [System.Windows.MessageBoxButton]::OKCancel
    $MessageIcon = [System.Windows.MessageBoxImage]::Error
 
    [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$Button,$MessageIcon)
}

