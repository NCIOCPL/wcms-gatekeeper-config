@Echo off
REM Generate the config files into place for development.
REM
REM Requires two environment variables:
REM     %GATEKEEPER_ROOT% - Points to the root of the GateKeeper project
REM     %GATEKEEPER_SUBST% - Path and filename of the substitution file.

REM Error checking
if "%GATEKEEPER_ROOT%" == "" (
    echo GATEKEEPER_ROOT must be set to the root of the GateKeeper project.
    goto :EOF
)
if "%GATEKEEPER_SUBST%" == "" (
    echo GATEKEEPER_SUBST must contain the path and filename of the substitution file.
    goto :EOF
)

REM Make config root the current directory.
pushd %~dp0 && cd ..
echo %cd%

REM GateKeeper apps
for %%a in (Admin CDRPreviewWS WebSvc) do (
    echo Generating '%GATEKEEPER_ROOT%\App\%%a\Web.config'
    powershell -ExecutionPolicy Unrestricted tools/substitution.ps1 -InputFile %%a\Web.config -OutputFile '%GATEKEEPER_ROOT%\App\%%a\Web.config' -SubstituteList '%GATEKEEPER_SUBST%'
)
echo Generating '%GATEKEEPER_ROOT%\App\ProcMgr\App.config'
powershell -ExecutionPolicy Unrestricted tools/substitution.ps1 -InputFile ProcMgr\App.config -OutputFile '%GATEKEEPER_ROOT%\App\ProcMgr\App.config' -SubstituteList '%GATEKEEPER_SUBST%'

REM Test harnesses.
echo Generating '%GATEKEEPER_ROOT%\Test Harnesses\PromotionTester\App.config'
powershell -ExecutionPolicy Unrestricted tools/substitution.ps1 -InputFile PromotionTester\App.config -OutputFile '%GATEKEEPER_ROOT%\Test Harnesses\PromotionTester\App.config' -SubstituteList '%GATEKEEPER_SUBST%'

echo Generating '%GATEKEEPER_ROOT%\Test Harnesses\UnitTest\UnitTest.dll.config'
powershell -ExecutionPolicy Unrestricted tools/substitution.ps1 -InputFile UnitTest\UnitTest.dll.config -OutputFile '%GATEKEEPER_ROOT%\Test Harnesses\UnitTest\UnitTest.dll.config' -SubstituteList '%GATEKEEPER_SUBST%'

echo Generating '%GATEKEEPER_ROOT%\Test Harnesses\ImportTool\App.config'
powershell -ExecutionPolicy Unrestricted tools/substitution.ps1 -InputFile ImportTool\App.config -OutputFile '%GATEKEEPER_ROOT%\Test Harnesses\ImportTool\App.config' -SubstituteList '%GATEKEEPER_SUBST%'



REM Return to original directory.
popd