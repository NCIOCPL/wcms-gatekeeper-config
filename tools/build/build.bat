@echo off
setlocal

@set PATH=C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\CommonExtensions\Microsoft\TestWindow;C:\Program Files (x86)\Microsoft SDKs\F#\3.1\Framework\v4.0\;C:\Program Files (x86)\Microsoft SDKs\TypeScript\1.0;C:\Program Files (x86)\MSBuild\12.0\bin;C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\;C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\BIN;C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools;C:\Windows\Microsoft.NET\Framework\v4.0.30319;C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\VCPackages;C:\Program Files (x86)\HTML Help Workshop;C:\Program Files (x86)\Microsoft Visual Studio 12.0\Team Tools\Performance Tools;C:\Program Files (x86)\Windows Kits\8.1\bin\x86;C:\Program Files (x86)\Microsoft SDKs\Windows\v8.1A\bin\NETFX 4.5.1 Tools\;%PATH%
@set INCLUDE=C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\INCLUDE;C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\ATLMFC\INCLUDE;C:\Program Files (x86)\Windows Kits\8.1\include\shared;C:\Program Files (x86)\Windows Kits\8.1\include\um;C:\Program Files (x86)\Windows Kits\8.1\include\winrt;
@set LIB=C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\LIB;C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\ATLMFC\LIB;C:\Program Files (x86)\Windows Kits\8.1\lib\winv6.3\um\x86;
@set LIBPATH=C:\Windows\Microsoft.NET\Framework\v4.0.30319;C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\LIB;C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\ATLMFC\LIB;C:\Program Files (x86)\Windows Kits\8.1\References\CommonConfiguration\Neutral;C:\Program Files (x86)\Microsoft SDKs\Windows\v8.1\ExtensionSDKs\Microsoft.VCLibs\12.0\References\CommonConfiguration\neutral;

set SCRIPT_DIR=%~dp0

REM Set the WORKSPACE environment variable to match the root directory
REM of the configuration file project.
pushd %~dp0 && cd ..\..
set WORKSPACE=%cd%

REM output location
if '%1' == '' GOTO HELP
SET OUTPUT_LOCATION=%1

REM text substitution file
if '%2' == '' GOTO HELP
set  SUBSTITUTION_LIST=%2

REM Create a temporary path variable, with a timestamp.
REM set the value in TEMP_PATH.
for /f "delims=: tokens=1-3" %%i in ("%time%") do @set TEMP_PATH=%temp%\%%i-%%j-%%k


REM As transforms are added for additional environments, add the environment
REM name to the list in this loop. Note that the environment name must match
REM the configuration name in the transform file name.
for %%a in ( prod ) do (
	msbuild /filelogger "/p:Environment=%%a;Output_Dir=%TEMP_PATH%" %SCRIPT_DIR%build.xml
)

REM Run the transformed files through the text substitution tool to produce the
REM final, deployment ready version of the files.
for %%a in ( prod ) do (
	REM web.config files.
	for %%b in (Admin CDRPreviewWS WebSvc) do (
		echo Generating '%OUTPUT_LOCATION%\%%a\%%b\Web.config'
		mkdir "%OUTPUT_LOCATION%\%%a\%%b\" 2> nul
		powershell -ExecutionPolicy Unrestricted %SCRIPT_DIR%scripts\substitution.ps1 -InputFile %TEMP_PATH%\%%a\%%b\Web.config -OutputFile '%OUTPUT_LOCATION%\%%a\%%b\Web.config' -SubstituteList '%SUBSTITUTION_LIST%'
	)
	REM Process Manager configuration
	echo Generating '%OUTPUT_LOCATION%\%%a\ProcMgr\processmanager.exe.config'
	mkdir "%OUTPUT_LOCATION%\%%a\ProcMgr\" 2> nul
	powershell -ExecutionPolicy Unrestricted %SCRIPT_DIR%scripts\substitution.ps1 -InputFile %TEMP_PATH%\%%a\ProcMgr\processmanager.exe.config -OutputFile '%OUTPUT_LOCATION%\%%a\ProcMgr\processmanager.exe.config' -SubstituteList '%SUBSTITUTION_LIST%'
)

REM Clean up
rd /s/q %TEMP_PATH%

GOTO :EOF
:HELP
echo.
echo. Usage:
echo.	build ^<output_location^> ^<substitution_list^>
echo.
echo. 	output_location - the location where the configuration files should be placed.
echo.
echo. 	substitution_list - path to the placeholder substitution file.
echo.
