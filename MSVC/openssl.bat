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
perl Configure VC-WIN64A
call ms\do_win64a
nmake -f ms\nt.mak