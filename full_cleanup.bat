@echo off
setlocal enabledelayedexpansion

REM === NVD SYSTEM CLEANUP ===

REM --- Timestamp ---
for /f "tokens=1-2 delims= " %%a in ('wmic os get localdatetime ^| find "."') do set dt=%%a
set datestamp=%dt:~0,4%-%dt:~4,2%-%dt:~6,2%
set timestamp=%dt:~8,2%:%dt:~10,2%:%dt:~12,2%

REM --- Disk Free Space BEFORE ---
for /f "tokens=*" %%i in ('fsutil volume diskfree C: 2^>nul ^| find "Total # of free bytes"') do (
    for %%j in (%%i) do set "free_before=%%j"
)
if not defined free_before set free_before=0
set /a gb_before=!free_before! / 1073741824

echo.
echo ===============================
echo      N V D  SYSTEM CLEAN
echo -------------------------------
echo   %datestamp% %timestamp%
echo ===============================
echo.

REM --- Count files in TEMP before ---
set "tempdir=%TEMP%"
for /f %%A in ('dir /a /s /b "%tempdir%" 2^>nul ^| find /c /v ""') do set temp_before=%%A

REM --- Cleanup ---
set "deleted=0"
set "killed=0"
for %%i in (node.exe Code.exe bash.exe wsl.exe) do (
    taskkill /f /im %%i >nul 2>&1 && (set /a killed+=1 & echo [+] Terminated %%i)
)

powershell.exe -command "Clear-RecycleBin -Force -Confirm:$false" >nul 2>&1 && echo [+] Recycle Bin cleared

rd /s /q "%TEMP%" >nul 2>&1
md "%TEMP%" >nul 2>&1

REM --- Count files in TEMP after ---
for /f %%A in ('dir /a /s /b "%tempdir%" 2^>nul ^| find /c /v ""') do set temp_after=%%A

REM --- Show deleted count ---
set /a deleted=temp_before-temp_after
if !deleted! lss 0 set deleted=0
echo [+] TEMP folders cleaned (!deleted! files deleted)

rd /s /q "C:\Windows\Temp" >nul 2>&1
md "C:\Windows\Temp" >nul 2>&1

where npm >nul 2>&1 && (call npm cache clean --force >nul 2>&1 && echo [+] npm cache cleaned)
where yarn >nul 2>&1 && (call yarn cache clean >nul 2>&1 && echo [+] yarn cache cleaned)

del /f /s /q C:\Thumbs.db >nul 2>&1
del /f /s /q C:\.DS_Store >nul 2>&1
echo [+] Metadata cleaned

REM --- Disk Free Space AFTER ---
for /f "tokens=*" %%i in ('fsutil volume diskfree C: 2^>nul ^| find "Total # of free bytes"') do (
    for %%j in (%%i) do set "free_after=%%j"
)
if not defined free_after set free_after=0
set /a gb_after=!free_after! / 1073741824
set /a gb_diff=gb_after-gb_before
if !gb_diff! lss 0 set gb_diff=0

REM --- End Timestamp ---
for /f "tokens=1-2 delims= " %%a in ('wmic os get localdatetime ^| find "."') do set dt=%%a
set endstamp=%dt:~0,4%-%dt:~4,2%-%dt:~6,2%
set endtime=%dt:~8,2%:%dt:~10,2%:%dt:~12,2%

echo.
echo ===============================
echo    NVD CLEANUP COMPLETE
echo    %endstamp% %endtime%
echo -------------------------------
echo   Storage before: !gb_before! GB
echo   Storage after : !gb_after! GB
echo   Space freed   : !gb_diff! GB
echo ===============================
echo.
pause >nul
