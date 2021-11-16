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
        [parameter(
            ValueFromPipeline=$true,
            ParameterSetName='byPipeline'
        )]
        [psobject]$InputObject,

        # An array of 2 int values for the UpperLeft corner, X first and then Y.
        [Parameter(
            ParameterSetName='byProperty'
        )]
        [AllowNull()]
        [ValidateCount(2,2)]
        [int[]]
        $Position,
        
        # An array of 2 int values for the width and height, X first and then Y.
        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName='byProperty'
        )]
        [AllowNull()]
        [ValidateCount(2,2)]
        [int[]]
        $Size,
        
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName='byProperty'
        )]
        [Alias('Id')]
        [int]
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
            # $OutputObject = [system.collections.arraylist]@()
        }
    }
    Process {

        foreach ($obj in $InputObject) {
            
            if ($PSCmdlet.ParameterSetName -eq 'byPipeline') {
                
                if ($obj.Return) {
                    Write-Verbose "Processing $($obj.Name) ..."
                    $x = $obj.Rectangle.UpperLeftX
                    $y = $obj.Rectangle.UpperLeftY
                    $Width = $obj.Size[0]
                    $Height = $obj.Size[1]
                    
                    
                    $Handles = @($Process.MainWindowHandle)

                    $Handle = $obj.Handle
                    $null = [Window]::MoveWindow($Handle, $x, $y, $Width, $Height, $True)
                    ### ISSUE: This $Handle needs to be re-grabbed from active windows.
                    # Then do a foreach and set each instance to the RECT.
                }

            } elseif ($PSCmdlet.ParameterSetName -eq 'byProperty') {

                $Process = Get-Process -Id $ProcessId
                Write-Verbose "Processing $($Process.Name) ..."
                $Handles = @($Process.MainWindowHandle)

                foreach ($Handle in $Handles) {
                    
                    $Rectangle = New-Object RECT
                    $Return = [Window]::GetWindowRect($Handle,[ref]$Rectangle)

                    if ($Return) {

                        if ($Size) {} else {
                            $Size = @()
                            $Size += [math]::Abs(($Rectangle.UpperLeftX - $Rectangle.LowerRightX))
                            $Size += [math]::Abs(($Rectangle.UpperLeftY - $Rectangle.LowerRightY))
                        }
                        
                        $x = $Rectangle.UpperLeftX
                        $y = $Rectangle.UpperLeftY
                        $Width  = $Size[0]
                        $Height = $Size[1]
                        $null = [Window]::MoveWindow($Handle, $x, $y, $Width, $Height, $True)
                    }

                }

                
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
