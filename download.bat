@echo off
setlocal

rem ANSI colors (Windows 10+): get the ESC character, then define color codes
for /F "delims=" %%a in ('forfiles /p "%~dp0." /m "%~nx0" /c "cmd /c echo 0x1B"') do set "ESC=%%a"
set "CYAN=%ESC%[96m"
set "GREEN=%ESC%[92m"
set "RED=%ESC%[91m"
set "RESET=%ESC%[0m"

set "STEAM_USERNAME="
set /p STEAM_USERNAME=Enter your Steam username:
if "%STEAM_USERNAME%"=="" (
    echo %RED%No username entered - stopping.%RESET%
    exit /b 1
)

echo %CYAN%=== Installing DepotDownloader ===%RESET%
curl -f -L -o DepotDownloader.zip https://github.com/SteamRE/DepotDownloader/releases/download/DepotDownloader_3.4.0/DepotDownloader-windows-x64.zip || goto :error
if not exist "DepotDownloader" mkdir "DepotDownloader"
tar -xf DepotDownloader.zip -C DepotDownloader || goto :error
del DepotDownloader.zip

echo %CYAN%=== Downloading Rec Room depot via DepotDownloader (will prompt for Steam password) ===%RESET%
DepotDownloader\DepotDownloader.exe -remember-password -app 471710 -depot 471711 -manifest 7859140924515540835 -dir . -username "%STEAM_USERNAME%" || goto :error

echo %CYAN%=== Writing steam_appid.txt ===%RESET%
>steam_appid.txt echo 480

echo %CYAN%=== Downloading BepInEx and extracting to this directory ===%RESET%
curl -f -L -o BepInEx.zip https://github.com/BepInEx/BepInEx/releases/download/v6.0.0-pre.2/BepInEx-Unity.IL2CPP-win-x64-6.0.0-pre.2.zip || goto :error
tar -xf BepInEx.zip -C . || goto :error
del BepInEx.zip

echo %CYAN%=== Downloading RecNetPlugin.dll into BepInEx\plugins ===%RESET%
if not exist "BepInEx\plugins" mkdir "BepInEx\plugins"
curl -f -L -o "BepInEx\plugins\RecNetPlugin.dll" https://github.com/djdevin/recnet-plugin/releases/download/0.0.3/RecNetPlugin.dll || goto :error

echo %CYAN%=== Extracting bundled global-metadata into RecRoom_Data\il2cpp_data\Metadata ===%RESET%
tar -xf "RecRoom_Data\il2cpp_data\Metadata\global-metadata.zip" -C "RecRoom_Data\il2cpp_data\Metadata" || goto :error

echo %GREEN%=== Done ===%RESET%
pause
exit /b 0

:error
echo.
echo %RED%*** FAILED with error code %errorlevel% - stopping. ***%RESET%
pause
exit /b %errorlevel%
