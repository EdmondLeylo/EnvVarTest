@ECHO off

IF "%~1"=="" (
SET ServerName=
SET DBName=
::If using sql server Integrated Security keep the Username and Password empty
SET Username=
SET Password=
) ELSE (
SET ServerName=%1
SET DBName=%2
SET Username=%3
SET Password=%4
)

SET DB_INFO=TRUE
IF [%ServerName%] == [] SET DB_INFO=FALSE
IF [%DBName%] == [] SET DB_INFO=FALSE
IF "%DB_INFO%" == "FALSE" (
	echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.
	echo :::::Error: Please provide the required missing info ServerName\DBName:::::.
	echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.
	exit /b 2 
)



SET INTEGRATED_SECURITY=FALSE
IF [%ServerName%] == [] SET INTEGRATED_SECURITY=TRUE
IF [%Password%] == [] SET INTEGRATED_SECURITY=TRUE

SET ReleaseDIR=%~dp0%..\db\
SET ReleaseDir=%ReleaseDir%%ReleaseNumber%\

IF NOT EXIST "%ReleaseDIR%index.txt" (

	echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.
	echo ::::: Error: "%ReleaseDIR%index.txt" was not found. The DB upgrade has terminated :::.
	echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.
	exit /b 3 
	

)

SET ReleaseFileName=%ReleaseNumber%.sql
SET ReleaseScriptFile=%ReleaseDIR%%ReleaseFileName%

::COPY /y NUL EmptyFile.sql >NUL

@ECHO IF app_name() ^<^> 'SQLCMD' RAISERROR('This script must be executed through SQLCMD', 20, 1) WITH LOG> "%ReleaseScriptFile%"
@ECHO :On Error Exit>> "%ReleaseScriptFile%"
@ECHO SET NOCOUNT ON>> "%ReleaseScriptFile%"
@ECHO SET XACT_ABORT ON;>> "%ReleaseScriptFile%"
@ECHO GO>> "%ReleaseScriptFile%"
@ECHO --Begin Transaction>> "%ReleaseScriptFile%"
@ECHO BEGIN TRAN;>> "%ReleaseScriptFile%"
@ECHO GO>> "%ReleaseScriptFile%"
FOR /F "usebackq tokens=* delims=" %%x in ("%ReleaseDIR%index.txt") DO (
	@ECHO :r $^(path^)%%x>> "%ReleaseScriptFile%"
	@ECHO GO>> "%ReleaseScriptFile%"	
)
@ECHO COMMIT TRAN;>> "%ReleaseScriptFile%"
@ECHO GO>> "%ReleaseScriptFile%"

IF NOT EXIST "%ReleaseScriptFile%" (

	echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.
	echo ::::: Error creating %ReleaseFileName%. The DB upgrade has terminated ::::::::::.
	echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.
	exit /b 4 
	

)

IF "%INTEGRATED_SECURITY%" == "TRUE" (	
    sqlcmd -S %ServerName% -d %DBName% -i "%ReleaseScriptFile%" -v path="%ReleaseDIR%"
)ELSE (	
	sqlcmd -S %ServerName% -d %DBName% -i "%ReleaseScriptFile%" -v path="%ReleaseDIR%"	-U %Username% -P %Password%
)

		
	IF ERRORLEVEL 1 GOTO err_handler

	IF "%INTEGRATED_SECURITY%" == "TRUE" (			
		sqlcmd -S %ServerName% -d %DBName% -Q "INSERT INTO DBVersionHistory (VersionNumber, Status) VALUES('%ReleaseNumber%', 1);"	
	)ELSE (	
		sqlcmd -S %ServerName% -d %DBName% -Q "INSERT INTO DBVersionHistory (VersionNumber, Status) VALUES('%ReleaseNumber%', 1);"	 -U %Username% -P %Password%
	)	
	echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.
	echo ::::: DB upgrade successful :::::::::::::::::::::::::::::::::::::::::::.
	echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.
	GOTO :END

	:err_handler
	
	IF "%INTEGRATED_SECURITY%" == "TRUE" (	
		sqlcmd -S %ServerName% -d %DBName% -Q "INSERT INTO DBVersionHistory (VersionNumber, Status) VALUES('%ReleaseNumber%', 0);"
	)ELSE (		
		sqlcmd -S %ServerName% -d %DBName% -Q "INSERT INTO DBVersionHistory (VersionNumber, Status) VALUES('%ReleaseNumber%', 0);"  -U %Username% -P %Password%
	)		
	echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.
	echo ::::: DB upgrade failed. The changes are Rolled back ::::::::::::::::::.
	echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.
	
	exit /b 5 

	:END
	
	
