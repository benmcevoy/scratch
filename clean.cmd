ECHO OFF
setlocal

ECHO This will delete all the bin and obj folders, so be careful
ECHO I expect to be running in a src folder

SET AREYOUSURE=N
:PROMPT
SET /P AREYOUSURE=Are you sure (Y/[N])?
IF /I "%AREYOUSURE%" NEQ "Y" GOTO END

ECHO ON
FOR /F "tokens=*" %%G IN ('DIR /B /AD /S bin') DO RMDIR /S /Q "%%G"
FOR /F "tokens=*" %%G IN ('DIR /B /AD /S obj') DO RMDIR /S /Q "%%G"

REM TO view effect, if using directly in cmd then use %G instead of %%G
REM FOR /F "tokens=*" %%G IN ('DIR /B /AD /S bin') DO ECHO "%%G"

:END
endlocal
