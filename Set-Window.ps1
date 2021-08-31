Function Set-Window {
    <#
    .SYNOPSIS
    Sets the window size (height,width) and coordinates (x,y) of
    a process window.

    .DESCRIPTION
    Sets the window size (height,width) and coordinates (x,y) of
    a process window.

    .NOTES
    Edited heavily by tony@pagliaro.co: 
    Taken from https://github.com/brad-do/ps-miscellany/blob/master/Set-Window.psm1
    [73ef6c4]...who appears to have taken it from:

    Name: Set-Window
    Author: Boe Prox
    Version History
        1.0//Boe Prox - 11/24/2015
            - Initial build

    .EXAMPLE
    Get-Content 'savedWindows.json' |
        ConvertFrom-Json |
        Set-Window

    Gets saved window data and applies it to the current window state.
    #>
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline=$True)]
        [psobject]$InputObject
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
            # $OutputObject = [system.collections.arraylist]@()
        }
    }
    Process {

        foreach ($obj in $InputObject) {
            
            if ($obj.Return) {
                Write-Verbose "Processing $($obj.Name) ..."
                $x = $obj.Rectangle.UpperLeftX
                $y = $obj.Rectangle.UpperLeftY
                $Width = $obj.Size[0]
                $Height = $obj.Size[1]
                $Handle = $obj.Handle
                $null = [Window]::MoveWindow($Handle, $x, $y, $Width, $Height, $True)
                ### ISSUE: This $Handle needs to be re-grabbed from active windows.
                # Then do a foreach and set each instance to the RECT.
            }

        }

    }

}

<#

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

#>
