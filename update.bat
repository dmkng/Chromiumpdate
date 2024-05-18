@if (@X)==(@Y) @end /*

@echo off
title Chromium Updater
cd/d %~dp0

if exist LAST_CHANGE goto rev

choice /c yn /n /m "Are you sure you want to download and unpack Chromium to %cd%? [Y/N]"
if %errorlevel% neq 1 exit /b
goto arch

:rev
set/p oldrev=<LAST_CHANGE
echo Current revision is %oldrev%

:arch
if "%PROCESSOR_ARCHITECTURE%"=="x86" (
	if not defined PROCESSOR_ARCHITEW6432 (
		set arch=Win
		goto get
	)
)
set arch=Win_x64

:get
echo Checking newest revision...
set url=https://storage.googleapis.com/chromium-browser-snapshots/%arch%/LAST_CHANGE
curl -sSfO %url%
if %errorlevel% equ 9009 (
	echo Using PowerShell instead...
	powershell -NoProfile -Command "(New-Object Net.WebClient).DownloadFile('%url%','LAST_CHANGE')"
) else if %errorlevel% neq 0 goto skip

set/p rev=<LAST_CHANGE
echo Newest revision is %rev%

if "%rev%"=="%oldrev%" goto skip

echo Downloading...
set url=https://storage.googleapis.com/chromium-browser-snapshots/%arch%/%rev%/chrome-win.zip
curl -fO %url%
if %errorlevel% equ 9009 (
	echo Using PowerShell instead...
	powershell -NoProfile -Command "(New-Object Net.WebClient).DownloadFile('%url%','chrome-win.zip')"
) else if %errorlevel% neq 0 goto skip

for /d %%a in ("*") do rd/s/q "%%a"
for %%a in ("*") do if not "%%a"=="%~nx0" if not "%%a"=="LAST_CHANGE" if not "%%a"=="chrome-win.zip" del/q "%%a"

echo Unpacking...

cscript /e:JScript /nologo "%~nx0" "%cd%"

move/y chrome-win\* . >nul
for /d %%a in ("chrome-win\*") do move/y "%%a" . >nul
rd/q chrome-win >nul

del/q chrome-win.zip >nul
goto run

:skip
timeout /t 1 /nobreak >nul 2>&1

:run
start .\chrome %*
exit /b

:: */

var f=new ActiveXObject("Scripting.FileSystemObject")
var s=new ActiveXObject("Shell.Application")
var l=s.NameSpace(WScript.arguments(0) + "\\chrome-win.zip\\chrome-win")
s.NameSpace(WScript.arguments(0)).CopyHere(l)
