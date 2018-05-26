Copyright (c) 2009-2012 Bitcoin Developers
Copyright (c) 2018 XP Developers
Distributed under the MIT/X11 software license, see the accompanying
file license.txt or http://www.opensource.org/licenses/mit-license.php.
This product includes software developed by the OpenSSL Project for use in
the OpenSSL Toolkit (http://www.openssl.org/).  This product includes
cryptographic software written by Eric Young (eay@cryptsoft.com).

See [readme-qt5.md](readme-qt5.md) for instructions on building XP QT, the
graphical user interface.

WINDOWS BUILD NOTES
===================

Compilers Supported
-------------------
XPCoin supports MSVC build.

Prepare
-------

setup follows software

- Visual Studio 2017 Community
- Chocolatey
- Qt 5.10.1 msvc 2015 32bit

DOS prompt:

```bat
MSVC\prepare.bat (execute by Admin permission.)
MSVC\boost.bat
MSVC\openssl.bat
MSVC\berkeleydb.bat
```

build berkeley db by using MSVC\db-4.8.30.NC\build_windowsBerkeley_DB.sln by yourself.


XPd
-------
DOS prompt:

```bat
cd \Path\To\XPCoin
cd src
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
cmake --build . --target ALL_BUILD -- /p:Configuration=Release
```
