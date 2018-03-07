@echo off
setlocal
set CURDIR=%~dp0
@echo on

call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" x86
cd %CURDIR%
del /S/Q db-4.8.30.NC.zip
rmdir /S/Q db-4.8.30.NC
curl -O http://download.oracle.com/berkeley-db/db-4.8.30.NC.zip
unzip db-4.8.30.NC.zip
cd db-4.8.30.NC
cd build_windows
devenv Berkeley_DB.sln /upgrade
:: msbuild Berkeley_DB.sln /p:Configuration="Debug" /p:Platform="win32" /p:PlatformToolset=v141
:: msbuild Berkeley_DB.sln /p:Configuration="Release" /p:Platform="win32" /p:PlatformToolset=v141