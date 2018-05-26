Copyright (c) 2009-2012 Bitcoin Developers
Copyright (c) 2013 XP Developers
Distributed under the MIT/X11 software license, see the accompanying
file license.txt or http://www.opensource.org/licenses/mit-license.php.
This product includes software developed by the OpenSSL Project for use in
the OpenSSL Toolkit (http://www.openssl.org/).  This product includes
cryptographic software written by Eric Young (eay@cryptsoft.com).


UNIX BUILD NOTES
================


To Build Automatic
------------------

Linux compile script (includes installing dependencies) (Non-GUI Version)(Deamon)  # Headless Xp

tested working on Ubuntu Server 64bit

wget https://github.com/eXperiencePoints/XPCoin/releases/download/1.0.0/XPd-linux-compile-from-source.sh
sudo sh ./XPd-linux-compile-from-source.sh

compiled file should be in XPCoin/src/ and is called XPd

----------------------------

To Build Manually
--------------------

cd src/
make -f makefile.unix            # Headless XP

See readme-qt.rst for instructions on building XP QT,
the graphical XP.

Dependencies
------------

 Library     Purpose           Description
 -------     -------           -----------
 libssl      SSL Support       Secure communications
 libdb4.8    Berkeley DB       Blockchain & wallet storage
 libboost    Boost             C++ Library
 libqrencode QRCode generation Optional QRCode generation

Note that libexecinfo should be installed, if you building under *BSD systems. 
This library provides backtrace facility.

libqrencode is used for QRCode image generation. It can be downloaded
from http://fukuchi.org/works/qrencode/index.html.en, or installed via
your package manager.

Licenses of statically linked libraries:
 Berkeley DB   New BSD license with additional requirement that linked
               software must be free open source
 Boost         MIT-like license

Versions used in this release:
 GCC           4.3.3
 OpenSSL       0.9.8g
 Berkeley DB   4.8.30.NC
 Boost         1.37

Dependency Build Instructions: Ubuntu & Debian
----------------------------------------------
sudo apt-get install build-essential
sudo apt-get install libssl-dev
sudo apt-get install libdb4.8-dev
sudo apt-get install libdb4.8++-dev
 Boost 1.40+: sudo apt-get install libboost-all-dev
 or Boost 1.37: sudo apt-get install libboost1.37-dev
sudo apt-get install libqrencode-dev

If using Boost 1.37, append -mt to the boost libraries in the makefile.


Dependency Build Instructions: Gentoo
-------------------------------------

Note: If you just want to install XPd on Gentoo, you can add the XP
      overlay and use your package manager:
          layman -a XP && emerge XPd

emerge -av1 --noreplace boost glib openssl sys-libs/db:4.8

Take the following steps to build:
 cd ${XP_DIR}/src
 make -f makefile.unix BDB_INCLUDE_PATH='/usr/include/db4.8'
 strip XPd


Notes
-----
The release is built with GCC and then "strip XPd" to strip the debug
symbols, which reduces the executable size by about 90%.

Berkeley DB
-----------
You need Berkeley DB 4.8.  If you have to build Berkeley DB yourself:
../dist/configure --enable-cxx
make


Boost
-----
If you need to build Boost yourself:
sudo su
./bootstrap.sh
./bjam install


Security
--------
To help make your XP installation more secure by making certain attacks impossible to
exploit even if a vulnerability is found, you can take the following measures:

* Position Independent Executable
    Build position independent code to take advantage of Address Space Layout Randomization
    offered by some kernels. An attacker who is able to cause execution of code at an arbitrary
    memory location is thwarted if he doesn't know where anything useful is located.
    The stack and heap are randomly located by default but this allows the code section to be
    randomly located as well.

    On an Amd64 processor where a library was not compiled with -fPIC, this will cause an error
    such as: "relocation R_X86_64_32 against `......' can not be used when making a shared object;"

    To build with PIE, use:
    make -f makefile.unix ... -e PIE=1

    To test that you have built PIE executable, install scanelf, part of paxutils, and use:
    scanelf -e ./XP

    The output should contain:
     TYPE
    ET_DYN

* Non-executable Stack
    If the stack is executable then trivial stack based buffer overflow exploits are possible if
    vulnerable buffers are found. By default, XP should be built with a non-executable stack
    but if one of the libraries it uses asks for an executable stack or someone makes a mistake
    and uses a compiler extension which requires an executable stack, it will silently build an
    executable without the non-executable stack protection.

    To verify that the stack is non-executable after compiling use:
    scanelf -e ./XP

    the output should contain:
    STK/REL/PTL
    RW- R-- RW-

    The STK RW- means that the stack is readable and writeable but not executable.
