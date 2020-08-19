@ECHO OFF
IF EXIST %1 (COPY %1 /B+ ,,/Y > nul) ELSE (TYPE nul >> %1)