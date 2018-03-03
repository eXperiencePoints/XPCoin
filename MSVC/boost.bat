@echo off
setlocal
set CURDIR=%~dp0
@echo on

rmdir /S/Q boost
git clone --recursive https://github.com/boostorg/boost.git || exit /b 1
cd %CURDIR%\boost
git checkout boost-1.66.0
call bootstrap.bat || exit /b 1
b2 toolset=msvc link=static,shared threading=multi variant=debug,release address-model=64 || exit /b 1
rmdir /S/Q %CURDIR%\lib\boost 
mkdir %CURDIR%\lib\boost\lib
copy %CURDIR%\boost\stage\lib  %CURDIR%\lib\boost\lib
mkdir %CURDIR%\lib\boost\include\boost
copy %CURDIR%\boost\boost  %CURDIR%\lib\boost\include\boost
