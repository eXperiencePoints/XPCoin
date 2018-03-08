@echo off
setlocal
set CURDIR=%~dp0
@echo on

:: rmdir /S/Q boost
:: git clone --recursive https://github.com/boostorg/boost.git || exit /b 1
:: cd %CURDIR%\boost
:: git checkout boost-1.66.0
:: call bootstrap.bat || exit /b 1
:: b2 toolset=msvc link=static,shared threading=multi variant=debug,release address-model=64 || exit /b 1
del /S/Q boost_1_66_0-bin-msvc-all-32-64.7z
rmdir /S/Q boost_1_66_0
curl -OL https://dl.bintray.com/boostorg/release/1.66.0/binaries/boost_1_66_0-bin-msvc-all-32-64.7z
7z x boost_1_66_0-bin-msvc-all-32-64.7z
:: rmdir /S/Q %CURDIR%\lib\boost
:: mkdir %CURDIR%\lib\boost\lib
:: xcopy /E/Q %CURDIR%\boost\stage\lib  %CURDIR%\lib\boost\lib
:: mkdir %CURDIR%\lib\boost\include\boost
:: xcopy /E/Q %CURDIR%\boost\boost  %CURDIR%\lib\boost\include\boost
