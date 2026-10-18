@echo off
setlocal

echo ===============================================================
echo     College Placement Management System - Launcher
echo ===============================================================

REM Locate Java 17
if exist "C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot\bin\java.exe" (
    set "JAVA_BIN=C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot\bin\java.exe"
    set "JAVAC_BIN=C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot\bin\javac.exe"
) else if defined JAVA_HOME (
    set "JAVA_BIN=%JAVA_HOME%\bin\java.exe"
    set "JAVAC_BIN=%JAVA_HOME%\bin\javac.exe"
) else (
    set "JAVA_BIN=java"
    set "JAVAC_BIN=javac"
)

echo [1/3] Checking compiled classes...
if not exist "bin\com\placement\Main.class" (
    echo Compiling Java source files...
    if not exist "bin" mkdir bin
    for /f "delims=" %%i in ('dir /s /b src\main\java\*.java') do (
        set "SOURCES=!SOURCES! "%%i""
    )
    "%JAVAC_BIN%" -encoding UTF-8 -cp "lib\mysql-connector-j-8.3.0.jar;lib\gson-2.10.1.jar" -d bin @sources.txt
    xcopy /s /y src\main\resources\* bin\
)

echo [2/3] Starting Backend Server on http://localhost:8080 ...
"%JAVA_BIN%" -cp "bin;lib\mysql-connector-j-8.3.0.jar;lib\gson-2.10.1.jar" com.placement.Main

pause
