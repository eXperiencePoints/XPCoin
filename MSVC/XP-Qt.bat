@echo off
setlocal
set CURDIR=%~dp0
set BASEDIR=%CURDIR%\..
@echo on

call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" x86
cd %BASEDIR%
nmake distclean
C:\Qt\5.10.1\msvc2015\bin\qmake.exe -spec win32-msvc || exit /b 1
jom || exit /b 1
rmdir /S/Q output\XP-Qt
mkdir output\XP-Qt
copy release\XP-Qt.exe output\XP-Qt
C:\Qt\5.10.1\msvc2015\bin\windeployqt --release output\XP-Qt\XP-Qt.exe || exit /b 1
copy MSVC\db-4.8.30.NC\build_windows\Win32\Release\libdb48.dll output\XP-Qt\