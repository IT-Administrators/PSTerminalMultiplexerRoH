# PowerShell Terminal Multiplexer

_The PSTerminalMultiplexer module creates a similar functionality of Windows Terminal, on Windows 10 and Windows Server._

## Table of contents

1. [Introduction](#introduction)
2. [Getting started](#getting-started)
    1. [Prerequisites](#system-prerequisites)
    2. [Installation](#installation)
3. [How to use](#What-the-module-does)
    1. [How to import](#how-to-import)
    2. [Using the functions](#using-the-functions)
4. [Known issues](#known-issues)
5. [License](/LICENSE)

## Introduction

If you are working with Linux, than you are propably familiar with the Linux commandline, and programms like tmux or terminator, to split your sessions and enhance productivity.

While Linux provides such programms to split your commandline sessions and arrange these session on your screen, depending on the keyboard shortcurt you pressed, Windows 10/ Windows Server doesn't provide this solution. Windows 11 comes preinstalled with Windows Terminal that has a similar functionality. 

While Windows Terminal is not available for Windows Server and doesn't come preinstalled on Windows 10, i wanted a similar functionality without the dependency on installing additional software.

After searching the internet for quite some time and not finding any similar programm for Windows Server, i decided to create this feature myself. While i had some failures with C# and because i didn't want to use 3rd party software and keep it as simple as possible, i came up with the idea to create this functionality with a PowerShell profile. This way it is compatible with PowerShell, my goto tool for configuring Windows and Linux via commandline. 

The module is also provided as a PowerShell profile, to use it on every session. The powershell profile is recommended.

## Getting started

### System prerequisites

-	Windows 10 / Windows Server (not tested on Windows 11)
-	PowerShell 5.1 or Higher

### Installation

The module is not published on PSGallery, so you can only download it from github.

You can download the module and the profile the following way:

1. Using Git
```Powershell
# Powershell
# Creates a directory in your current directory.
md PSTerminalMultiplexer
# Change location to the created directory.
cd PSTerminalMultiplexer
# Pull necessary files.
git pull "https://github.com/IT-Administrators/PSTerminalMultiplexer.git"
```
2. Using Powershell
```Powershell
# Download zip archive using powershell.
Invoke-WebRequest -Uri "https://github.com/IT-Administrators/PSTerminalMultiplexer/archive/refs/heads/main.zip" -OutFile "PSTerminalMultiplexer.zip"
# Than expand archive.
Expand-Archive -Path ".\PSTerminalMultiplexer.zip"
```
## What the module does

The PSTerminalMultiplexer module implements two functions, to generate the abbility to split your screen or the current session by half, either vertical or horizontal. 

Functions:
-	```Split-Vertical```
-	```Split-Horizontal```

Before downloading the script or copying the code into your current profile, i recommend reading the MS articel about_profiles and all sub articles related to PowerShell profiles.

## How to import

If you downloaded the module or copied the profile in your ```$Profile``` directory. You will see two functions exported from that module. 
```PowerShell
# Show functions from PSTerminalMultiplexer module.
Get-Command -Module PSTerminalMultiplexerRoH

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        prompt                                             0.0        PSTerminalMultiplexerRoH
Function        Split-Horizontal                                   0.0        PSTerminalMultiplexerRoH
Function        Split-Vertical                                     0.0        PSTerminalMultiplexerRoH
```

Be careful the ```prompt``` function is overwritten, to show a welcome message.
```PowerShell
Welcome to PowerShell Terminal Multiplexer.
You can split your screen vertical by using the function <Split-Vertical>
or horizontal by using the function <Split-Horizontal>.
To get help on how to use these functions use Get-Help <FunctionName> -Full.
```
If you don't want the ```prompt``` function to be owerwritten, use the following snippet:

```PowerShell
Import-Module .\PSTerminalMultiplexerRoH.psm1 -Function "Split-Vertical","Split-Horizontal" -Force -Verbose
```
## Using the functions

The following example can also be done using PowerShell jobs, with the ```Start-Job``` cmdlet. But while you using ```Start-Job``` cmdlet, you need to actively track the job result, by calling ```Get-Job | Receive-Job -Keep```, this might interfere with your workflow. 

Or what if you need to run a script that prompts for credentials? You can run that script from the current session but than you need to open another one, because the current one will be blocked while executing the script and you adjust the sessions on your screen and all that. 

That's where the functions ```Split-Vertical``` and ```Split-Horizontal``` come in handy. 

```Careful: the commandline is cleared when calling the functions.```

To differ from the default PowerShell session, importing the module or using the profile changes the backgroundcolor to black and the letters to white. Also the console title is set to ```PS TerminalMultiplexer```.

Let's say you want to test if every machine inside your network is reachable via ping.

![image](https://user-images.githubusercontent.com/91905626/209559312-1fbfd83f-8de3-4c56-90b5-14c9aa85dc2a.png)

While running the connection test in the old session (which is blocked until the execution is finished or canceled), another session opens. The new session is on the same coordinates as the old session, but with half the size and the old session is also devided by half. You can than work in the new session, with the same command history of the old session.

Example of a script/ cmdlet that prompts for credentials in the old session:

![image](https://user-images.githubusercontent.com/91905626/209560156-5c34aafc-2a4d-4812-ac62-543bca39f14f.png)

![image](https://user-images.githubusercontent.com/91905626/209564228-3a1bdcbc-9890-41ff-ab42-d2c8281c7c8c.png)

Every new session is a Windows PowerShell session. This profile is specifically made for Windows PowerShell. If you need another commandline like PowerShell-Core (PowerShell 7+) or the standard Windows commandline cmd, you can switch to them by using the commands "pwsh" or "cmd" in your current session.

To get help on the functions use:

```PowerShell
# Works only if module was imported before.
Get-Help -Name <FunctionName> -Full
```
Get help on the profile use:

```PowerShell
# Works only in is current location is the profile directory.
Get-Help -Name .\profile.ps1 -Full
```

## Known Issues

-	Gab between sessions, they are not docking right next to each other (vertical and horizontal).
-	Doesn't work with Exchange Management Shell.
	- If you want to have the same functionality like the exchange management shell, you need to import the exchange module into a normal PowerShell session.
- If you change the $NewConsole variable to pwsh, "Start-Process pwsh -PassThru" (line 130,242) and adjust the last line of each function (line 160,272) to "pwsh -command $ScriptBlock", every second session will be Windows Powershell and the code is also run in Windows PowerShell. This might happen if you use both PowerShell Versions on the same system, although it should run Side-by-Side.
