@echo off
setlocal
set CURDIR=%~dp0
@echo on

rmdir /S/Q openssl
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
cd %CURDIR%
git clone https://github.com/openssl/openssl.git
cd openssl
git checkout OpenSSL_1_0_2n
perl Configure VC-WIN64A || exit /b 1
call ms\do_win64a || exit /b 1
nmake -f ms\nt.mak || exit /b 1

rmdir /S/Q %CURDIR%\lib\openssl
mkdir %CURDIR%\lib\openssl\lib
copy %CURDIR%\openssl\out32  %CURDIR%\lib\openssl\lib
mkdir %CURDIR%\lib\openssl\include\openssl
copy %CURDIR%\openssl\inc32\openssl  %CURDIR%\lib\openssl\include\openssl