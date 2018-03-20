@echo off
REM Generate the config files into place for development.
REM
REM Requires two arguemnts:
REM     Arg 1 (GATEKEEPER_ROOT) - Points to the root of the GateKeeper project
REM     Arg 2 (SUBSTITUTION_LIST) - Path and filename of the substitution file.
REM
REM Command Line option:
REM     --deploy-only - Toggles the generation of only the files which are included
REM                     in a deployment.

set SCRIPT_DIR=%~dp0



REM Error checking

REM output location
if '%1' == '' GOTO HELP
SET GATEKEEPER_ROOT=%1

REM text substitution file
if '%2' == '' GOTO HELP
set  SUBSTITUTION_LIST=%2

SET DEPLOY_ONLY=false
IF '%1' == '--deploy-only' SET DEPLOY_ONLY=true

REM Make config root the current directory.
pushd %~dp0 && cd ..\..

REM GateKeeper apps
for %%a in (Admin CDRPreviewWS WebSvc) do (
    echo Generating '%GATEKEEPER_ROOT%\App\%%a\Web.config'
    mkdir "%GATEKEEPER_ROOT%\App\%%a" 2> nul
    powershell -ExecutionPolicy Unrestricted %SCRIPT_DIR%scripts\substitution.ps1 -InputFile %%a\Web.config -OutputFile '%GATEKEEPER_ROOT%\App\%%a\Web.config' -SubstituteList '%SUBSTITUTION_LIST%'
)

REM The Process Manager config has a different name for development vs. deployment.
IF '%DEPLOY_ONLY%' == 'false' (
    SET PROCMGR_FILENAME=App.config
) ELSE (
    SET PROCMGR_FILENAME=ProcessManager.exe.config
)

echo Generating '%GATEKEEPER_ROOT%\App\ProcMgr\%PROCMGR_FILENAME%'
mkdir "%GATEKEEPER_ROOT%\App\ProcMgr" 2> nul
powershell -ExecutionPolicy Unrestricted %SCRIPT_DIR%scripts\substitution.ps1 -InputFile ProcMgr\App.config -OutputFile '%GATEKEEPER_ROOT%\App\ProcMgr\%PROCMGR_FILENAME%' -SubstituteList '%SUBSTITUTION_LIST%'


REM Test harness and database connection files are only needed in a development environment.
IF '%DEPLOY_ONLY%' == 'false' (
    REM Test harnesses.
    for %%a in (PromotionTester ImportTool ProcessTester PubPreviewTest) do (
        echo Generating '%GATEKEEPER_ROOT%\Test Harnesses\%%a\App.config'
        mkdir "%GATEKEEPER_ROOT%\Test Harnesses\%%a" 2> nul
        powershell -ExecutionPolicy Unrestricted %SCRIPT_DIR%scripts\substitution.ps1 -InputFile %%a\App.config -OutputFile '%GATEKEEPER_ROOT%\Test Harnesses\%%a\App.config' -SubstituteList '%SUBSTITUTION_LIST%'
    )
    echo Generating '%GATEKEEPER_ROOT%\Test Harnesses\UnitTest\UnitTest.dll.config'
    mkdir "%GATEKEEPER_ROOT%\Test Harnesses\UnitTest" 2> nul
    powershell -ExecutionPolicy Unrestricted %SCRIPT_DIR%scripts\substitution.ps1 -InputFile UnitTest\UnitTest.dll.config -OutputFile '%GATEKEEPER_ROOT%\Test Harnesses\UnitTest\UnitTest.dll.config' -SubstituteList '%SUBSTITUTION_LIST%'

    REM GateKeeperTest config
    echo Generating '%GATEKEEPER_ROOT%\Test Harnesses\GateKeeperTest\GateKeeperTest.exe.config'
    mkdir "%GATEKEEPER_ROOT%\Test Harnesses\GateKeeperTest" 2> nul
    powershell -ExecutionPolicy Unrestricted %SCRIPT_DIR%scripts\substitution.ps1 -InputFile GateKeeperTest\GateKeeperTest.exe.config -OutputFile '%GATEKEEPER_ROOT%\Test Harnesses\GateKeeperTest\GateKeeperTest.exe.config' -SubstituteList '%SUBSTITUTION_LIST%'

    REM database connections
    for %%a in (Admin CDRPreviewWS WebSvc ProcMgr) do (
        echo Generating '%GATEKEEPER_ROOT%\App\%%a\connectionStrings.config'
        mkdir "%GATEKEEPER_ROOT%\App\%%a\" 2> nul
        powershell -ExecutionPolicy Unrestricted %SCRIPT_DIR%scripts\substitution.ps1 -InputFile sharedconfig\connectionStrings.config -OutputFile '%GATEKEEPER_ROOT%\App\%%a\connectionStrings.config' -SubstituteList '%SUBSTITUTION_LIST%'
    )
    for %%a in (UnitTest PromotionTester) do (
        echo Generating '%GATEKEEPER_ROOT%\Test Harnesses\%%a\connectionStrings.config'
        mkdir "%GATEKEEPER_ROOT%\Test Harnesses\%%a\" 2> nul
        powershell -ExecutionPolicy Unrestricted %SCRIPT_DIR%scripts\substitution.ps1 -InputFile sharedconfig\connectionStrings.config -OutputFile '%GATEKEEPER_ROOT%\Test Harnesses\%%a\connectionStrings.config' -SubstituteList '%SUBSTITUTION_LIST%'
    )
)

REM Return to original directory.
popd

GOTO :EOF
:HELP
echo.
echo. Usage:
echo.   build4dev  ^<output_location^> ^<substitution_list^> [--deploy-only]
echo.
echo. 	output_location - the location where the configuration files should be placed.
echo.
echo. 	substitution_list - path to the placeholder substitution file.
echo.
echo. 	--deploy-only (optional) - if specified, only the files which are included in
echo.                              a deployment are generated.
echo.
