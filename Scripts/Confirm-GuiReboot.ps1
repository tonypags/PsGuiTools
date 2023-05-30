Function Get-PendingReboot {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("CN", "Computer")]
        [String[]]$ComputerName = "$env:COMPUTERNAME",
        [String]$ErrorLog
    )

    Begin {  }## End Begin Script Block
    Process {
        Foreach ($Computer in $ComputerName) {
            Try {
                ## Setting pending values to false to cut down on the number of else statements
                $CompPendRen, $PendFileRename, $Pending, $SCCM = $false, $false, $false, $false

                ## Setting CBSRebootPend to null since not all versions of Windows has this value
                $CBSRebootPend = $null

                ## Querying WMI for build version
                $WMI_OS = Get-CimInstance -Class Win32_OperatingSystem -Property BuildNumber, CSName -ComputerName $Computer -ErrorAction Stop

                ## Making registry connection to the local/remote computer
                $HKLM = [UInt32] "0x80000002"
                $WMI_Reg = [WMIClass] "\\$Computer\root\default:StdRegProv"

                ## If Vista/2008 & Above query the CBS Reg Key
                If ([Int32]$WMI_OS.BuildNumber -ge 6001) {
                    $RegSubKeysCBS = $WMI_Reg.EnumKey($HKLM, "SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\")
                    $CBSRebootPend = $RegSubKeysCBS.sNames -contains "RebootPending"		
                }

                ## Query WUAU from the registry
                $RegWUAURebootReq = $WMI_Reg.EnumKey($HKLM, "SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\")
                $WUAURebootReq = $RegWUAURebootReq.sNames -contains "RebootRequired"

                ## Query PendingFileRenameOperations from the registry
                $RegSubKeySM = $WMI_Reg.GetMultiStringValue($HKLM, "SYSTEM\CurrentControlSet\Control\Session Manager\", "PendingFileRenameOperations")
                $RegValuePFRO = $RegSubKeySM.sValue

                ## Query JoinDomain key from the registry - These keys are present if pending a reboot from a domain join operation
                $Netlogon = $WMI_Reg.EnumKey($HKLM, "SYSTEM\CurrentControlSet\Services\Netlogon").sNames
                $PendDomJoin = ($Netlogon -contains 'JoinDomain') -or ($Netlogon -contains 'AvoidSpnSet')

                ## Query ComputerName and ActiveComputerName from the registry
                $ActCompNm = $WMI_Reg.GetStringValue($HKLM, "SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName\", "ComputerName")            
                $CompNm = $WMI_Reg.GetStringValue($HKLM, "SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\", "ComputerName")

                If (($ActCompNm -ne $CompNm) -or $PendDomJoin) {
                    $CompPendRen = $true
                }

                ## If PendingFileRenameOperations has a value set $RegValuePFRO variable to $true
                If ($RegValuePFRO) {
                    $PendFileRename = $true
                }

                ## Determine SCCM 2012 Client Reboot Pending Status
                ## To avoid nested 'if' statements and unneeded WMI calls to determine if the CCM_ClientUtilities class exist, setting EA = 0
                $CCMClientSDK = $null
                $CCMSplat = @{
                    NameSpace    = 'ROOT\ccm\ClientSDK'
                    Class        = 'CCM_ClientUtilities'
                    Name         = 'DetermineIfRebootPending'
                    ComputerName = $Computer
                    ErrorAction  = 'Stop'
                }
                ## Try CCMClientSDK
                Try {
                    $CCMClientSDK = Invoke-WmiMethod @CCMSplat
                }
                Catch [System.UnauthorizedAccessException] {
                    $CcmStatus = Get-Service -Name CcmExec -ComputerName $Computer -ErrorAction SilentlyContinue
                    If ($CcmStatus.Status -ne 'Running') {
                        Write-Warning "$Computer`: Error - CcmExec service is not running."
                        $CCMClientSDK = $null
                    }
                }
                Catch {
                    $CCMClientSDK = $null
                }

                If ($CCMClientSDK) {
                    If ($CCMClientSDK.ReturnValue -ne 0) {
                        Write-Warning "Error: DetermineIfRebootPending returned error code $($CCMClientSDK.ReturnValue)"          
                    }
                    If ($CCMClientSDK.IsHardRebootPending -or $CCMClientSDK.RebootPending) {
                        $SCCM = $true
                    }
                }

                Else {
                    $SCCM = $null
                }

                ## Creating Custom PSObject and Select-Object Splat
                $SelectSplat = @{
                    Property = (
                        'Computer',
                        'CBServicing',
                        'WindowsUpdate',
                        'CCMClientSDK',
                        'PendComputerRename',
                        'PendFileRename',
                        'PendFileRenVal',
                        'RebootPending'
                    )
                }
                New-Object -TypeName PSObject -Property @{
                    Computer           = $WMI_OS.CSName
                    CBServicing        = $CBSRebootPend
                    WindowsUpdate      = $WUAURebootReq
                    CCMClientSDK       = $SCCM
                    PendComputerRename = $CompPendRen
                    PendFileRename     = $PendFileRename
                    PendFileRenVal     = $RegValuePFRO
                    RebootPending      = ($CompPendRen -or $CBSRebootPend -or $WUAURebootReq -or $SCCM -or $PendFileRename)
                } | Select-Object @SelectSplat

            }
            Catch {
                Write-Warning "$Computer`: $_"
                ## If $ErrorLog, log the file to a user specified location/path
                If ($ErrorLog) {
                    Out-File -InputObject "$Computer`,$_" -FilePath $ErrorLog -Append
                }
            }
        }## End Foreach ($Computer in $ComputerName)
    }## End Process

    End {  }## End End

}## End Function Get-PendingReboot

# Check the local status in real time
$Reboot = Get-PendingReboot
if ($Reboot.RebootPending) {

    # Are any of the modes true?
    if (-not(
            $Reboot.CBServicing -or
            $Reboot.WindowsUpdate -or
            $Reboot.PendComputerRename
        )) {
        # If nothing is required, break out
        break
    }

    # Build out the language
    [string]$MessageBody = @"
        This computer is pending a reboot.

        Please save all work before restarting.

        Would you like to restart now?
"@
    [string]$MessageTitle = "Computer Reboot Warning"

    # Build out the GUI Popup
    Add-Type -AssemblyName PresentationCore, PresentationFramework
    $ButtonType = [System.Windows.MessageBoxButton]::YesNo
    $MessageIcon = [System.Windows.MessageBoxImage]::Question

    # Ask the user
    $YN = [System.Windows.MessageBox]::Show($MessageBody, $MessageTitle, $ButtonType, $MessageIcon)

    # Handle the answer
    if ($YN -eq 'Yes') {

        # Double check in case the click is an accident
        [string]$MessageBody = "Are you sure? `nPlease save your work before clicking YES."
        $MessageIcon = [System.Windows.MessageBoxImage]::Warning
        $YN = [System.Windows.MessageBox]::Show($MessageBody, $MessageTitle, $ButtonType, $MessageIcon)

        # Reboot the PC
        if ($YN -eq 'Yes') {Restart-Computer -Confirm:$false -Force}
    }
}
