@ECHO OFF
set MSI_HOME=%~dp0
setlocal EnableDelayedExpansion
set pathName=%1
if exist %MSI_HOME%OfferServiceSetup.msi (
GOTO :UNINSTALL
REM 
) else (
ECHO Skipping OfferService
call :color 0C "%MSI_HOME%OfferServiceSetup.msi not found. Installation failed."
echo[
pause
exit /b 2
)

:INSTALL
ECHO Waiting for the uninstall to finish ...
ping 127.0.0.1 -n 11 > nul
ECHO Install OfferService
if "%~1"==""  (
	echo Enter the path to the setParam.xml file:
	set /p pathName=%=%
  )
msiexec /qn /l* install.log /i "%MSI_HOME%OfferServiceSetup.msi" ALLUSERS=2 configFile=!pathName!
if errorlevel 1 goto :INSTALLATIONFAILED
if %ERRORLEVEL% == 0 goto :INSTALLATIONSUCCEEDED

:UNINSTALL
ECHO Uninstall OfferService
sc stop OfferService
msiexec /qn /x {0D58A4F0-10A0-40F3-8258-6833B1D6DBD8} /L*V! uninstall.log
goto :INSTALL

:INSTALLATIONSUCCEEDED
call :color 0a "OfferService successfully installed."
echo[
pause
exit /b

:INSTALLATIONFAILED
call :color 0C "OfferService failed to install."
echo[
pause
exit /b 2

:color
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "DEL=%%a"
)
<nul > X set /p ".=."
set "param=^%~2" !
set "param=!param:"=\"!"
findstr /p /A:%1 "." "!param!\..\X" nul
<nul set /p ".=%DEL%%DEL%%DEL%%DEL%%DEL%%DEL%%DEL%"
del /s X  >nul 2>&1
exit /b