:: Jaromil's dotfiles
::
:: Install ADMIN environment
@echo off

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Setup needs administrator rights...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
echo Running with Administrator privileges.
echo .
echo Installing winget packages...
winget install JFLarvoire.Ag Genivia.ugrep GnuWin32.Tar GnuWin32.Which GNU.Emacs Microsoft.Git GitHub.cli KeePassXCTeam.KeePassXC GnuWin32.File GnuWin32.Findutils GnuWin32.Grep GnuWin32.Tree GnuWin32.Diffutils GnuWin32.Gzip GnuWin32.Unzip GnuWin32.Zip GnuPG.GnuPG direnv.direnv Dyne.CJIT Kitware.CMake Ninja-build.Ninja mesonbuild.meson Ccache.Ccache BurntSushi.ripgrep.MSVC

echo Setting up Windows Firewall
call :BlockInternet "keepassxc"
call :BlockInternet "ugrep"
call :BlockInternet "grep"
call :BlockInternet "ag"
call :BlockInternet "tar"
call :BlockInternet "make"
call :BlockInternet "which"
call :BlockInternet "file"
call :BlockInternet "find"
call :BlockInternet "tree"
call :BlockInternet "diff"
call :BlockInternet "gzip"
call :BlockInternet "unzip"
call :BlockInternet "zip"
call :BlockInternet "gpg"
call :BlockInternet "direnv"
call :BlockInternet "cjit"
call :BlockInternet "cmake"
call :BlockInternet "ninja"
call :BlockInternet "meson"
call :BlockInternet "ccache"
call :BlockInternet "ripgrep"


set "DEV=%USERPROFILE%\devel"
powershell -NoProfile -Command "Add-MpPreference -ExclusionPath '%DEV%'"
echo Defender exclusion added for:
echo %DEV%

pause
exit /b 0

:BlockInternet
set "APP=%~1"
set "RULE=%~2"

if "%APP%"=="" exit /b 1
if "%RULE%"=="" exit /b 1

for /f "delims=" %%I in ('which "%APP%" 2^>nul') do (
  set "APP=%%I"
  goto :BlockInternetFound
)

echo Could not find executable with which: "%APP%"
exit /b 1

:BlockInternetFound
for %%I in ("%APP%") do set "APP=%%~fI"

echo Block "%APP%" Internet

netsh advfirewall firewall add rule name="%RULE% outbound" dir=out action=block program="%APP%" enable=yes
netsh advfirewall firewall add rule name="%RULE% inbound" dir=in action=block program="%APP%" enable=yes

echo Blocked: "%APP%"
exit /b 0
