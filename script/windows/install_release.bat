@echo off

set folderName=%1
set folderPath=%2
set downloadFileName=%3
set execPath=%4
set createdFolder=%5

powershell -command "Start-Sleep -s 2"

tar -xf %folderPath%\%downloadFileName% -C %folderPath%
if %createdFolder% neq %folderName% (
    xcopy %folderPath%\%createdFolder% %folderPath%\%folderName% /Y /S
    rmdir /s /q %folderPath%\%createdFolder%
)
del %folderPath%\%downloadFileName%
start /b "" cmd /c %execPath% /b
start /b "" cmd /c del %folderPath%\install_release.bat&exit /b
