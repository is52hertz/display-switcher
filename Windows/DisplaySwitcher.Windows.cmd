@echo off
setlocal DisableDelayedExpansion

set "displaySwitcherAction=%~1"
set "displaySwitcherComputer=%~2"
set "displaySwitcherExtra=%~3"
setlocal EnableDelayedExpansion

if /i "!displaySwitcherAction!"=="probe" if "!displaySwitcherComputer!"=="" goto probe
if /i "!displaySwitcherAction!"=="get-input" if "!displaySwitcherComputer!"=="" goto getinput
if /i "!displaySwitcherAction!"=="switch" if /i "!displaySwitcherComputer!"=="windows" if "!displaySwitcherExtra!"=="" goto windows
if /i "!displaySwitcherAction!"=="switch" if /i "!displaySwitcherComputer!"=="mac" if "!displaySwitcherExtra!"=="" goto mac

>&2 echo error: use probe, get-input, switch windows, or switch mac
exit /b 64

:probe
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0DisplaySwitcher.Windows.ps1" -Action Probe
exit /b %errorlevel%

:getinput
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0DisplaySwitcher.Windows.ps1" -Action GetInput
exit /b %errorlevel%

:windows
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0DisplaySwitcher.Windows.ps1" -Action Switch -Computer Windows
exit /b %errorlevel%

:mac
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0DisplaySwitcher.Windows.ps1" -Action Switch -Computer Mac
exit /b %errorlevel%
