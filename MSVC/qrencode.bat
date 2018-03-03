@echo off
setlocal
set CURDIR=%~dp0
@echo on

rmdir /S/Q libqrencode
git clone https://github.com/Naruto/libqrencode.git || exit /b 1
cd libqrencode
git checkout feature/strict_check_include_file
mkdir build
cd build
cmake -DWITH_TOOLS=NO -DWITH_TESTS=NO -DCMAKE_CONFIGURATION_TYPES=Release .. || exit /b 1
cmake --build . --clean-first  -- /p:Configuration=Release || exit /b 1