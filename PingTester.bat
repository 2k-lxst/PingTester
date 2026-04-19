@echo off
title PingTester

set currentDir=%cd%
echo %currentDir% > resources\path.txt

Ping www.google.nl -n 1 -w 1000

cls

if errorlevel 1 (
   start resources\mbd.vbs
   exit
) else (
   set internet=Successfully connected to the internet
   timeout 3 > nul
)

echo %internet%
timeout 2 > nul

setlocal enabledelayedexpansion
set count=0

for /f "delims=" %%a in (config.txt) do (
    set /a count+=1

    if !count! == 1 (
        set host=%%a
    ) else if !count! == 2 (
        set times=%%a
        call :ping !host! !times!
        set count=0
    )
)

:ping
cd resources\temp
>temp ping -a %~1 -n %~2

for /f "tokens=2 delims=[]" %%a in (temp) do set ip=%%a
for /f "tokens=2 delims=(" %%a in ('find "(" temp') do set loss=%%a
for /f "tokens=4 delims==" %%a in ('find "ms, " temp') do set avrg=%%a

cls

echo.

echo    Successfully pinged %ip% (%~1) %~2 times with %loss: loss),=% loss and the average time of response (ping) of %avrg:~1%
echo.
echo    IP: %ip% (%~1)
echo    Pinged: %~2 times
echo    Packet loss: %loss: loss),=%
echo    Average time of response (Ping): %avrg:~1%

:eof
echo.
set /p exit=Save results in a file [Y/N]? 
if /i "%exit%"=="y" goto savefile
if /i "%exit%"=="n" goto discard

:savefile

cd..
cd..

del results.txt

echo Successfully pinged %ip% (%~1) %~2 times with %loss: loss),=% loss and the average time of response (ping) of %avrg:~1% >> results.txt
echo. >> results.txt
echo IP: %ip% (%~1) >> results.txt
echo Pinged: %~2 times >> results.txt
echo Packet loss: %loss: loss),=% >> results.txt
echo Average time of response (Ping): %avrg:~1% >> results.txt

pause

:discard
exit
