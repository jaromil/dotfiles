:: Jaromil's dotfiles
::
:: Install USER environment (no admin permission needed)
:: Needs some winget packages installed so first run:
:: ./install/windows-admin.bat

@echo off
set "HOME=%USERPROFILE%"
:: path to dotfiles
set "R=%~dp0.."
for %%I in ("%R%") do set "R=%%~fI"

echo Installing Dotfiles from: %R%

:: robocopy "%R%\" "C:\target\files" /E
copy /Y "%R%\emacs\emacs" "%HOME%\.emacs"
copy /Y "%R%\git\gitconfig" "%HOME%\.gitconfig"
copy /Y "%R%\git\gitignore" "%HOME%\.gitignore"
copy /Y "%R%\misc\editorconfig" "%HOME%\.editorconfig"
copy /Y "%R%\misc\signature" "%HOME%\.signature"


:: find runemacs.exe and create lnk with correct startup dir
for /f "usebackq delims=" %%I in (`
  powershell -NoProfile -Command "Get-ChildItem '%ProgramFiles%\Emacs\emacs-*\bin\runemacs.exe' | Sort-Object FullName -Descending | Select-Object -First 1 -ExpandProperty FullName"
`) do set "EMACS_EXE=%%I"
if not defined EMACS_EXE (
  echo runemacs.exe not found
  exit /b 1
)
for %%D in ("%EMACS_EXE%\..\..") do set "EMACS_DIR=%%~fD"
for %%D in ("%EMACS_DIR%") do set "EMACS_VER=%%~nxD"
set "LNK_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\%EMACS_VER%"
set "LNK=%LNK_DIR%\Emacs.lnk"
if not exist "%LNK_DIR%" mkdir "%LNK_DIR%"
powershell -NoProfile -Command "$w = New-Object -ComObject WScript.Shell; $s = $w.CreateShortcut('%LNK%'); $s.TargetPath = '%EMACS_EXE%'; $s.WorkingDirectory = '%USERPROFILE%'; $s.Save()"
echo Shortcut updated:
echo "%LNK%"
echo Target:
echo "%EMACS_EXE%"
