# College Placement Management System - PowerShell Launcher
$ErrorActionPreference = "Stop"

Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "     College Placement Management System - Launcher" -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Cyan

# Locate Java 17
$javaBin = "java"
$javacBin = "javac"
$temurin17 = "C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot\bin"

if (Test-Path "$temurin17\java.exe") {
    $javaBin = "$temurin17\java.exe"
    $javacBin = "$temurin17\javac.exe"
} elseif ($env:JAVA_HOME -and (Test-Path "$env:JAVA_HOME\bin\java.exe")) {
    $javaBin = "$env:JAVA_HOME\bin\java.exe"
    $javacBin = "$env:JAVA_HOME\bin\javac.exe"
}

Write-Host "[1/2] Compiling Java classes..." -ForegroundColor Yellow
if (-not (Test-Path "bin")) { New-Item -ItemType Directory -Path "bin" | Out-Null }

$sources = Get-ChildItem -Recurse -Filter "*.java" src\main\java | ForEach-Object { $_.FullName }
& $javacBin -encoding UTF-8 -cp "lib\mysql-connector-j-8.3.0.jar;lib\gson-2.10.1.jar" -d bin $sources

Copy-Item -Path "src\main\resources\*" -Destination "bin\" -Recurse -Force

Write-Host "[2/2] Starting College Placement Server on http://localhost:8080 ..." -ForegroundColor Green
& $javaBin -cp "bin;lib\mysql-connector-j-8.3.0.jar;lib\gson-2.10.1.jar" com.placement.Main
