@echo off
setlocal
set CURDIR=%~dp0
set BASEDIR=%CURDIR%\..
@echo on

cd %BASEDIR%
cd src
rmdir /S/Q build
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release .. || exit /b 1
cmake --build . --target ALL_BUILD -- /p:Configuration=Release || exit /b 1

cd %BASEDIR%
rmdir /S/Q output/XPd
mkdir output\XPd
copy src\build\Release\XPd.exe output\XPd\
copy MSVC\db-4.8.30.NC\build_windows\Win32\Release\libdb48.dll output\XPd\
