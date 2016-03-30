@ECHO off

set HOME_DIR=%~dp0

set WEBADMIN_HOME=%HOME_DIR%..\webAdmin
set WEBAPI_HOME=%HOME_DIR%..\WebAPI
set INTERNALAPI_HOME=%HOME_DIR%..\InternalAPI


IF "%OFFER_SERVICE_ENV_TYPE%" == "DEV" (
	set _DeploySetParametersFile=%HOME_DIR%DEV\setParam.xml
) ELSE IF "%OFFER_SERVICE_ENV_TYPE%" == "INT" (
	set _DeploySetParametersFile=%HOME_DIR%INT\setParam.xml
) ELSE IF "%OFFER_SERVICE_ENV_TYPE%" == "PROD" (
	set _DeploySetParametersFile=%HOME_DIR%PROD\setParam.xml
) ELSE IF "%OFFER_SERVICE_ENV_TYPE%" == "LOCAL" (
	set _DeploySetParametersFile=%HOME_DIR%LOCAL\setParam.xml
) ELSE (
	goto :SETOSENVPATH
)

echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo ::::: This script will install Offer Service applications to ::::::::
echo ::::::::::::::::::::::::---------::::::::::::::::::::::::::::::::::::
echo ":::::::::::::::::::::::   %OFFER_SERVICE_ENV_TYPE%   :::::::::::::::::::::::::::::::::::"
echo ::::::::::::::::::::::::---------::::::::::::::::::::::::::::::::::::
echo ::::: 1) WebAdmin :::::::::::::::::::::::::::::::::::::::::::::::::::
echo ::::: 2) WebAPI :::::::::::::::::::::::::::::::::::::::::::::::::::::
echo ::::: 3) InternalAPI ::::::::::::::::::::::::::::::::::::::::::::::::
echo ::::: 4) OfferService Windows Service :::::::::::::::::::::::::::::::
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo Note: The script will pause waiting for a key press before moving on:
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo "Ready to deploy WebAdmin application..."
pause
call %WEBADMIN_HOME%\Kikai.WebAdmin.deploy.cmd /Y

echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo :::::::::::: Done Deploying WebAdmin ::::::::::::::::::::::::::::::::
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo "Ready to deploy WebAPI..."
pause
call %WEBAPI_HOME%\Kikai.WebAPI.deploy.cmd /Y

echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo :::::::::::: Done Deploying WebAPI ::::::::::::::::::::::::::::::::::
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo "Ready to deploy InternalAPI..."
pause
call %INTERNALAPI_HOME%\Kikai.InternalAPI.deploy.cmd /Y

echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo :::::::::::: Done Deploying InternalAPI :::::::::::::::::::::::::::::
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo "Ready to deploy OfferService Windows Service..."
pause
call %HOME_DIR%OfferServiceInstall.bat %_DeploySetParametersFile%

echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo :::::::::::: Done Installing OfferService Windows Service :::::::::::
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo "Ready to upgrade the database to the latest version..."
pause

%HOME_DIR%UpgradeDbWrapper.exe %_DeploySetParametersFile% "KikaiDB-Web.config Connection String" "%HOME_DIR%UpgradeDB.bat"

echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo :::::::::::: Done Upgrading the database to the latest version ::::::
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo "Ready to run the sanity check..."
pause

%HOME_DIR%SanityChecker\OfferServiceSanityChecker.exe -r -s %_DeploySetParametersFile%
pause
goto :END

:SETOSENVPATH
echo "The environment variable OFFER_SERVICE_ENV_TYPE is not set properly"
echo "Allowed values are DEV, INT and PROD"
echo "Value found is %OFFER_SERVICE_ENV_TYPE%
pause

:END