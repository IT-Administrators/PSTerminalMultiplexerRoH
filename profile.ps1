<#
.Synopsis
    PowerShell profile
    
.DESCRIPTION
    This file implements functions to customize your powershell session.
    You need to download this script or copy paste the code into your own profile. 
    To use a profile you need to adjust the executionpolicy.
    For further reference, on how to use profiles look at the link section.

.NOTES
    Written and testet in PowerShell 5.1.
    Compatible with PowerShell Core (7.+) on Windows.
    Not compatible with PowerShell Core on Linux. 
    
.LINK
    Profile
    https://github.com/IT-Administrators/PSTerminalMultiplexerRoH
    Profile reference microsoft
    Get-Help about_profiles
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.3
#>

$Host.UI.RawUI.BackgroundColor = 'black'
$Host.UI.RawUI.ForegroundColor = 'white'
$Host.UI.RawUI.WindowTitle = 'PS TerminalMultiplexer'
Clear-Host
$Host.UI.WriteLine(
"Welcome to PowerShell Terminal Multiplexer.
You can split your screen vertical by using the function <Split-Vertical> 
or horizontal by using the function <Split-Horizontal>.
To get help on how to use these functions use Get-Help <FunctionName> -Full.
`n"
)

#Prompt function
function prompt{
    $CurrentTime = (Get-Date).ToLongTimeString()
    $CurrentDate = (Get-Date).ToShortDateString()

    $CurrentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $AdminRole = $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    "UserName: " + $env:USERNAME + " MachineName: " + $env:COMPUTERNAME + " CurrentDate: " + $CurrentDate + " " + $CurrentTime + "`n" + `
    $(if($AdminRole){
        ("$([char]0x1b)[38;5;$(196)m$("[ADMIN]: ")$([char]0x1b)[0m")
    }) + "PS " + (Get-Location) + ">"
}

#Add .NET type
Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class Terminal {
        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
        [DllImport("user32.dll")]
        public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
    }
    public struct RECT
    {
        public int Left;        // x position of upper-left corner
        public int Top;         // y position of upper-left corner
        public int Right;       // x position of lower-right corner
        public int Bottom;      // y position of lower-right corner
    }
"@

<#
.Synopsis
    Splits the current session vertical.
    
.DESCRIPTION
    Splits the current session vertical (by half) and docks the new session to the right. Both sessions have together the same size as the first one.

.EXAMPLE
    Call <Split-Vertical> to just split your session. Your main window will be the new session.
    Split-Vertical
    Opens new powershell window and docks it to the right, with half the size of the first one. And adjusts the size of the first session equaly.

.EXAMPLE
    This example shows one way to pipe commands into the <Split-Vertical> function. Every command needs to be enclosed with curly brackets. That's because of the way a scriptblock is implemented in powershell.
    Here a scriptblock variable is used, that contains the command. After declaration the scriptblock is piped to the function. The scriptblock variable has the same name as the function parameter. 
    #Define the scriptblock variable.
    $Scriptblock = {Get-Process "*power*"}
    #Opens new console and runs scriptblock in old console.
    $Scriptblock | Split-Vertical

.EXAMPLE
    Another way to pipe commands into the <Split-Vertical> function. This way the command is piped directly into the function an doesn't require the scriptblock variable, as shown in the last example.
    You don't need the scriptblock variable if you enclose the command with curly brackets.
    #Opens new console and runs scriptblock in old console.
    {Get-Process "*power*"} | Split-Vertical
    
.NOTES
    Written and testet in PowerShell 5.1.
    Compatible with PowerShell Core (7.+) on Windows.
    Not compatible with PowerShell Core on Linux. 
    
.LINK
    https://github.com/IT-Administrators/PSTerminalMultiplexerRoH
#>

function Split-Vertical{

    param(
    [Parameter(ValueFromPipeline=$true)]
    [Scriptblock]$Scriptblock = {""}
    )

    $Handle = (Get-Process -Id $PID).MainWindowHandle

    #Current process window size
    $ConsoleRect = New-Object RECT
    [Terminal]::GetWindowRect($Handle,[Ref]$ConsoleRect)

    #New process
    $NewConsole = Start-Process PowerShell -PassThru
    Start-Sleep -Milliseconds 500
    $HandleNew = $NewConsole.MainWindowHandle

    #New process window size
    $ConsoleRectNew = New-Object RECT
    [Terminal]::GetWindowRect($HandleNew,[Ref]$ConsoleRectNew)

    if($HandleNew -eq [IntPtr]::Zero){
        Write-Output "Cannot find window with this handle."
        exit
    }

    #Move old console
    [void][Terminal]::MoveWindow($Handle, $ConsoleRect.Left, $ConsoleRect.Top, ($ConsoleRect.Right - $ConsoleRect.Left) /2, ($ConsoleRect.Bottom - $ConsoleRect.Top), $true)

    #Move new console
    [void][Terminal]::MoveWindow($HandleNew, $ConsoleRect.Left + ($ConsoleRect.Right - $ConsoleRect.Left) /2, $ConsoleRect.Top, ($ConsoleRect.Right - $ConsoleRect.Left) / 2, ($ConsoleRect.Bottom - $ConsoleRect.Top), $true)
    
    #Runs command in current session
    powershell -command $Scriptblock
}

<#
.Synopsis
    Splits the current session horizontal.
    
.DESCRIPTION
    Splits the current session horizontal (by half) and docks the new session underneath it. Both sessions have together the same size as the first one.

.EXAMPLE
    Call <Split-Horizontal> to just split your session. You main window will be the new session.
    Split-Horizontal

.EXAMPLE
    This example shows one way to pipe commands into the <Split-Horizontal> function. Every command needs to be enclosed with curly brackets. That's because of the way a scriptblock is implemented in powershell.
    Here a scriptblock variable is used, that contains the command. After declaration the scriptblock is piped to the function. The scriptblock variable has the same name as the function parameter. 
    #Define the scriptblock variable.
    $Scriptblock = {Get-Process "*power*"}
    #Opens new console and runs scriptblock in old console.
    $Scriptblock | Split-Horizontal

.EXAMPLE
    Another way to pipe commands into the <Split-Horizontal> function. This way the command is piped directly into the function an doesn't require the scriptblock variable, as shown in the last example.
    You don't need the scriptblock variable, if you enclose the command with curly brackets.
    #Opens new console and runs scriptblock in old console.
    {Get-Process "*power*"} | Split-Horizontal
    
.NOTES
    Written and testet in PowerShell 5.1.
    Compatible with PowerShell Core (7.+) on Windows.
    Not compatible with PowerShell Core on Linux. 
    
.LINK
    https://github.com/IT-Administrators/PSTerminalMultiplexerRoH
#>

function Split-Horizontal{

    param(
    [Parameter(ValueFromPipeline=$true)]
    [Scriptblock]$Scriptblock = {""}
    )

    $Handle = (Get-Process -Id $PID).MainWindowHandle

    if($Handle -eq [IntPtr]::Zero){
        Write-Output "Cannot find window with this handle."
        exit
    }

    #Current process window size
    $ConsoleRect = New-Object RECT
    [Terminal]::GetWindowRect($Handle,[Ref]$ConsoleRect)

    #New process
    $NewConsole = Start-Process PowerShell -PassThru
    Start-Sleep -Milliseconds 500
    $HandleNew = $NewConsole.MainWindowHandle

    #New process window size
    $ConsoleRectNew = New-Object RECT
    [Terminal]::GetWindowRect($HandleNew,[Ref]$ConsoleRectNew)

    if($HandleNew -eq [IntPtr]::Zero){
        Write-Output "Cannot find window with this handle."
        exit
    }

    #Move old console
    [void][Terminal]::MoveWindow($Handle, $ConsoleRect.Left, $ConsoleRect.Top, ($ConsoleRect.Right - $ConsoleRect.Left), ($ConsoleRect.Bottom - $ConsoleRect.Top) /2, $true)

    #Move new console
    [void][Terminal]::MoveWindow($HandleNew, $ConsoleRect.Left, $ConsoleRect.Top + ($ConsoleRect.Bottom - $ConsoleRect.Top) /2, ($ConsoleRect.Right - $ConsoleRect.Left), ($ConsoleRect.Bottom -$ConsoleRect.Top) /2, $true)
    
    #Runs command in current session
    powershell -command $Scriptblock
}