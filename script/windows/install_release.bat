@echo off

@REM just to be sure that DeepFaceLabClient is closed
timeout 2

set folderName=%1
set folderPath=%2
set downloadFileName=%3
set execPath=%4
set createdFolder=%5

if exist %folderPath%\%folderName% rmdir %folderPath%\%folderName% /q /s
tar -xf %folderPath%\%downloadFileName% -C %folderPath%
@REM to preserve shortcut and symbolic link
move %folderPath%\%createdFolder% %folderPath%\%folderName%
%execPath%
