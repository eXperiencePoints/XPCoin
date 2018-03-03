@echo off
setlocal

choco install -y git || exit /b 1
choco install -y curl || exit /b 1
choco install -y strawberryperl
choco install -y cmake --installargs 'ADD_CMAKE_TO_PATH=System' || exit /b 1
refreshenv || exit /b 1
