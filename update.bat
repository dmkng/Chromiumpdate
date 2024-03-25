@if (@X)==(@Y) @end /*

@echo off
title Chromium Updater
cd/d %~dp0

if exist updaterev goto rev

choice /c yn /n /m "Are you sure you want to download and unpack Chromium to %cd%? [Y/N]"
if %errorlevel% NEQ 1 exit /b
goto arch

:rev
set/p oldrev=<updaterev
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
for /f "delims=" %%a in ('curl -sS "https://download-chromium.appspot.com/rev/%arch%?type=snapshots"') do (
	set rev=%%a
	goto dwn
)
goto skip

:dwn
set "rev=%rev:*content":"=%"
set "rev=%rev:"=" & ::%"
echo Newest revision is %rev%

if "%rev%"=="%oldrev%" goto skip

echo Downloading...

curl -O "https://storage.googleapis.com/chromium-browser-snapshots/%arch%/%rev%/chrome-win.zip"
if %errorlevel% NEQ 0 goto skip

for /d %%a in ("*") do rd/s/q "%%a"
for %%a in ("*") do if not "%%a"=="%~nx0" if not "%%a"=="chrome-win.zip" del/q "%%a"

echo %rev%>updaterev

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
start .\chrome
exit /b

:: */

var f=new ActiveXObject("Scripting.FileSystemObject")
var s=new ActiveXObject("Shell.Application")
var l=s.NameSpace(WScript.arguments(0) + "\\chrome-win.zip\\chrome-win")
s.NameSpace(WScript.arguments(0)).CopyHere(l)
