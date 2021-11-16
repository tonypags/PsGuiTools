Function Get-Window {
    <#
    .SYNOPSIS
    Gets the window size (height,width) and coordinates (x,y) of
    a process window.

    .DESCRIPTION
    Gets the window size (height,width) and coordinates (x,y) of
    a process window.

    .PARAMETER ProcessId
    Id of the process to determine the window characteristics

    .NOTES
    Taken from https://github.com/brad-do/ps-miscellany/blob/master/Set-Window.psm1
    [73ef6c4]...who appears to have taken it from:

    Name: Set-Window
    Author: Boe Prox
    Version History
        1.0//Boe Prox - 11/24/2015
            - Initial build

    .OUTPUTS
    System.Automation.WindowInfo

    .EXAMPLE
    Get-Process notepad | Get-Window | convertto-json
    {
    "Return":  true,
    "Rectangle":  {
        "UpperLeftX":  -364,
        "UpperLeftY":  -1079,
        "LowerRightX":  299,
        "LowerRightY":  -655
    },
    "Size":  [
        663,
        424
        ],
        "Handle":  2230422,
        "ProcessId":  10300,
        "Name":  "notepad"
    } 
    .EXAMPLE
    Get-Process notepad | Get-Window | convertto-json | Out-File 'savedWindows.json'

    Saves the output to file
    #>
    [OutputType('System.Automation.WindowInfo')]
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipelineByPropertyName=$True)]
        [Alias('Id')]
        $ProcessId
    )

    Begin {

        Try{
            [void][Window]
        } Catch {
        Add-Type @"
              using System;
              using System.Runtime.InteropServices;
              public class Window {
                [DllImport("user32.dll")]
                [return: MarshalAs(UnmanagedType.Bool)]
                public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

                [DllImport("User32.dll")]
                public extern static bool MoveWindow(IntPtr handle, int x, int y, int width, int height, bool redraw);
              }
              public struct RECT
              {
                public int UpperLeftX;    // x position of upper-left corner
                public int UpperLeftY;    // y position of upper-left corner
                public int LowerRightX;   // x position of lower-right corner
                public int LowerRightY;   // y position of lower-right corner
              }
"@
        }

    }

    Process {
        
        foreach ($Id in $ProcessId) {

            $Rectangle = New-Object RECT
            $Process = Get-Process -Id $Id
            $Name = $Process.Name
            $Handle = $Process.MainWindowHandle
            $Return = [Window]::GetWindowRect($Handle,[ref]$Rectangle)

            $SizeX = [math]::Abs(($Rectangle.UpperLeftX - $Rectangle.LowerRightX))
            $SizeY = [math]::Abs(($Rectangle.UpperLeftY - $Rectangle.LowerRightY))

            [PSCustomObject]@{
                Return = [bool]$Return
                Rectangle = [RECT]$Rectangle
                Size = [int[]]@($SizeX, $SizeY)
                Handle = [int]$Handle
                ProcessId = [int]$Id
                Name = [string]$Name
            }
            
        }#ENS: foreach ($Id in $ProcessId) {}
        
    }#END: Process {}

}
