@echo off
setlocal
set CURDIR=%~dp0
@echo on

del /S/Q db-4.8.30.NC.zip
rmkdir /S/Q db-4.8.30.NC
curl -O http://download.oracle.com/berkeley-db/db-4.8.30.NC.zip
unzip db-4.8.30.NC.zip
