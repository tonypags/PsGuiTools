function Invoke-GuiPopupWarningOK {
    param (
        [string]$MessageBody,
        [string]$MessageTitle
    )

    Add-Type -AssemblyName PresentationCore,PresentationFramework
    $ButtonType = [System.Windows.MessageBoxButton]::OK
    $MessageIcon = [System.Windows.MessageBoxImage]::Warning
 
    [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
}
