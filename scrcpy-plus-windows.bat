@echo off
REM ============================================================================
REM scrcpy-plus v3 — Windows GUI & CLI Launcher
REM Developer : Subuh Kurniawan <kurrniawansubuh@gmail.com>
REM ============================================================================
setlocal
cd /d "%~dp0"

if "%~1"=="--build-exe" (
    echo Building standalone scrcpy-plus-gui.exe using PyInstaller...
    python -m pip install --upgrade pyinstaller
    python -m PyInstaller --noconfirm --onefile --windowed --name "scrcpy-plus-gui" "scrcpy-plus-gui-crossplatform.py"
    if exist "dist\scrcpy-plus-gui.exe" copy /y "dist\scrcpy-plus-gui.exe" "scrcpy-plus-gui.exe"
    echo Done! Standalone executable created: scrcpy-plus-gui.exe
    pause
    exit /b 0
)

REM If standalone scrcpy-plus-gui.exe exists, launch it directly
if exist "%~dp0scrcpy-plus-gui.exe" (
    start "" "%~dp0scrcpy-plus-gui.exe"
    exit /b 0
)

REM Otherwise launch via pythonw / pyw / python
where pythonw >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    start "" pythonw "%~dp0scrcpy-plus-gui-crossplatform.py"
    exit /b 0
)

where pyw >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    start "" pyw "%~dp0scrcpy-plus-gui-crossplatform.py"
    exit /b 0
)

where python >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    start "" python "%~dp0scrcpy-plus-gui-crossplatform.py"
    exit /b 0
)

echo [Error] Python 3 tidak ditemukan di Windows Anda.
echo Silakan install Python 3 dari https://www.python.org/downloads/ (centang "Add Python to PATH").
pause
exit /b 1
