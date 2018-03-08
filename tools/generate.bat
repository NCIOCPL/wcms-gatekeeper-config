@echo off
REM Generate the config files into place for development.
REM
REM Requires two environment variables:
REM     %GATEKEEPER_ROOT% - Points to the root of the GateKeeper project
REM     %GATEKEEPER_SUBST% - Path and filename of the substitution file.
REM
REM Command Line option:
REM     --deploy-only - Toggles the generation of only the files which are included
REM                     in a deployment.

REM Error checking
if "%GATEKEEPER_ROOT%" == "" (
    echo GATEKEEPER_ROOT must be set to the root of the GateKeeper project.
    goto :EOF
)
if "%GATEKEEPER_SUBST%" == "" (
    echo GATEKEEPER_SUBST must contain the path and filename of the substitution file.
    goto :EOF
)

SET DEPLOY_ONLY=false
IF '%1' == '--deploy-only' SET DEPLOY_ONLY=true

REM Make config root the current directory.
pushd %~dp0 && cd ..

REM GateKeeper apps
for %%a in (Admin CDRPreviewWS WebSvc) do (
    echo Generating '%GATEKEEPER_ROOT%\App\%%a\Web.config'
    mkdir "%GATEKEEPER_ROOT%\App\%%a" 2> nul
    powershell -ExecutionPolicy Unrestricted tools/substitution.ps1 -InputFile %%a\Web.config -OutputFile '%GATEKEEPER_ROOT%\App\%%a\Web.config' -SubstituteList '%GATEKEEPER_SUBST%'
)

REM The Process Manager config has a different name for development vs. deployment.
IF '%DEPLOY_ONLY%' == 'false' (
    SET PROCMGR_FILENAME=App.config
) ELSE (
    SET PROCMGR_FILENAME=ProcessManager.exe.config
)

echo Generating '%GATEKEEPER_ROOT%\App\ProcMgr\%PROCMGR_FILENAME%'
mkdir "%GATEKEEPER_ROOT%\App\ProcMgr" 2> nul
powershell -ExecutionPolicy Unrestricted tools/substitution.ps1 -InputFile ProcMgr\App.config -OutputFile '%GATEKEEPER_ROOT%\App\ProcMgr\%PROCMGR_FILENAME%' -SubstituteList '%GATEKEEPER_SUBST%'


REM Test harness and database connection files are only needed in a development environment.
IF '%DEPLOY_ONLY%' == 'false' (
    REM Test harnesses.
    for %%a in (PromotionTester ImportTool ProcessTester PubPreviewTest) do (
        echo Generating '%GATEKEEPER_ROOT%\Test Harnesses\%%a\App.config'
        mkdir "%GATEKEEPER_ROOT%\Test Harnesses\%%a" 2> nul
        powershell -ExecutionPolicy Unrestricted tools/substitution.ps1 -InputFile %%a\App.config -OutputFile '%GATEKEEPER_ROOT%\Test Harnesses\%%a\App.config' -SubstituteList '%GATEKEEPER_SUBST%'
    )
    echo Generating '%GATEKEEPER_ROOT%\Test Harnesses\UnitTest\UnitTest.dll.config'
    mkdir "%GATEKEEPER_ROOT%\Test Harnesses\UnitTest" 2> nul
    powershell -ExecutionPolicy Unrestricted tools/substitution.ps1 -InputFile UnitTest\UnitTest.dll.config -OutputFile '%GATEKEEPER_ROOT%\Test Harnesses\UnitTest\UnitTest.dll.config' -SubstituteList '%GATEKEEPER_SUBST%'

    REM GateKeeperTest config
    echo Generating '%GATEKEEPER_ROOT%\Test Harnesses\GateKeeperTest\GateKeeperTest.exe.config'
    mkdir "%GATEKEEPER_ROOT%\Test Harnesses\GateKeeperTest" 2> nul
    powershell -ExecutionPolicy Unrestricted tools/substitution.ps1 -InputFile GateKeeperTest\GateKeeperTest.exe.config -OutputFile '%GATEKEEPER_ROOT%\Test Harnesses\GateKeeperTest\GateKeeperTest.exe.config' -SubstituteList '%GATEKEEPER_SUBST%'

    REM database connections
    for %%a in (Admin CDRPreviewWS WebSvc ProcMgr) do (
        echo Generating '%GATEKEEPER_ROOT%\App\%%a\sharedconfig\connectionStrings.config'
        mkdir "%GATEKEEPER_ROOT%\App\%%a\sharedconfig\" 2> nul
        powershell -ExecutionPolicy Unrestricted tools/substitution.ps1 -InputFile sharedconfig\connectionStrings.config -OutputFile '%GATEKEEPER_ROOT%\App\%%a\sharedconfig\connectionStrings.config' -SubstituteList '%GATEKEEPER_SUBST%'
    )
    for %%a in (UnitTest PromotionTester) do (
        echo Generating '%GATEKEEPER_ROOT%\Test Harnesses\%%a\sharedconfig\connectionStrings.config'
        mkdir "%GATEKEEPER_ROOT%\Test Harnesses\%%a\sharedconfig\" 2> nul
        powershell -ExecutionPolicy Unrestricted tools/substitution.ps1 -InputFile sharedconfig\connectionStrings.config -OutputFile '%GATEKEEPER_ROOT%\Test Harnesses\%%a\sharedconfig\connectionStrings.config' -SubstituteList '%GATEKEEPER_SUBST%'
    )
)

REM Return to original directory.
popd
