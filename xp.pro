TEMPLATE = app
TARGET = XP-qt
VERSION = 1.1.0.2
INCLUDEPATH += src src/json src/qt
QT += core gui network
greaterThan(QT_MAJOR_VERSION, 4): QT += widgets
DEFINES += QT_GUI BOOST_THREAD_USE_LIB BOOST_SPIRIT_THREADSAFE __STDC_FORMAT_MACROS __STDC_LIMIT_MACROS
CONFIG += no_include_pwd
CONFIG += thread
CONFIG += static

freebsd-g++: QMAKE_TARGET.arch = $$QMAKE_HOST.arch
linux-g++: QMAKE_TARGET.arch = $$QMAKE_HOST.arch
linux-g++-32: QMAKE_TARGET.arch = i686
linux-g++-64: QMAKE_TARGET.arch = x86_64
win32-g++-cross: QMAKE_TARGET.arch = $$TARGET_PLATFORM
win32-msvc: QMAKE_TARGET.arch = i686

OBJECTS_DIR = build
MOC_DIR = build
UI_DIR = build

# use: qmake "RELEASE=1"
contains(RELEASE, 1) {
    CONFIG += Release
    macx:QMAKE_CXXFLAGS += -mmacosx-version-min=10.7
    macx:QMAKE_CFLAGS += -mmacosx-version-min=10.7
    macx:QMAKE_OBJECTIVE_CFLAGS += -mmacosx-version-min=10.7
}

!win32 {
# for extra security against potential buffer overflows: enable GCCs Stack Smashing Protection
QMAKE_CXXFLAGS *= -fstack-protector-all --param ssp-buffer-size=1
QMAKE_LFLAGS *= -fstack-protector-all --param ssp-buffer-size=1
# We need to exclude this for Windows cross compile with MinGW 4.2.x, as it will result in a non-working executable!
# This can be enabled for Windows, when we switch to MinGW >= 4.4.x.
}
# for extra security on Windows: enable ASLR and DEP via GCC linker flags

# TODO: msvs requests follow parameters
# win32:QMAKE_LFLAGS *= -Wl,--dynamicbase -Wl,--nxcompat
# win32:QMAKE_LFLAGS += -static-libgcc -static-libstdc++

# use: qmake "USE_DBUS=1"
contains(USE_DBUS, 1) {
    message(Building with DBUS (Freedesktop notifications) support)
    DEFINES += USE_DBUS
    QT += dbus
}

# use: qmake "USE_IPV6=1" ( enabled by default; default)
#  or: qmake "USE_IPV6=0" (disabled by default)
#  or: qmake "USE_IPV6=-" (not supported)
contains(USE_IPV6, -) {
    message(Building without IPv6 support)
} else {
    count(USE_IPV6, 0) {
        USE_IPV6=1
    }
    DEFINES += USE_IPV6=$$USE_IPV6
}

contains(BITCOIN_NEED_QT_PLUGINS, 1) {
    DEFINES += BITCOIN_NEED_QT_PLUGINS
    QTPLUGIN += qcncodecs qjpcodecs qtwcodecs qkrcodecs qtaccessiblewidgets
}

contains(USE_LEVELDB, 1) {
    message(Building with LevelDB transaction index)
    DEFINES += USE_LEVELDB

    INCLUDEPATH += src/leveldb/include src/leveldb/helpers
    LIBS += $$PWD/src/leveldb/libleveldb.a $$PWD/src/leveldb/libmemenv.a
    SOURCES += src/txdb-leveldb.cpp
    !win32 {
        # we use QMAKE_CXXFLAGS_RELEASE even without RELEASE=1 because we use RELEASE to indicate linking preferences not -O preferences
        genleveldb.commands = cd $$PWD/src/leveldb && CC=$$QMAKE_CC CXX=$$QMAKE_CXX $(MAKE) OPT=\"$$QMAKE_CXXFLAGS $$QMAKE_CXXFLAGS_RELEASE\" libleveldb.a libmemenv.a
    } else {
        # make an educated guess about what the ranlib command is called
        isEmpty(QMAKE_RANLIB) {
            QMAKE_RANLIB = $$replace(QMAKE_STRIP, strip, ranlib)
        }
        LIBS += -lshlwapi
        #genleveldb.commands = cd $$PWD/src/leveldb && CC=$$QMAKE_CC CXX=$$QMAKE_CXX TARGET_OS=OS_WINDOWS_CROSSCOMPILE $(MAKE) OPT=\"$$QMAKE_CXXFLAGS $$QMAKE_CXXFLAGS_RELEASE\" libleveldb.a libmemenv.a && $$QMAKE_RANLIB $$PWD/src/leveldb/libleveldb.a && $$QMAKE_RANLIB $$PWD/src/leveldb/libmemenv.a
    }
    genleveldb.target = $$PWD/src/leveldb/libleveldb.a
    genleveldb.depends = FORCE
    PRE_TARGETDEPS += $$PWD/src/leveldb/libleveldb.a
    QMAKE_EXTRA_TARGETS += genleveldb
    # Gross ugly hack that depends on qmake internals, unfortunately there is no other way to do it.
    QMAKE_CLEAN += $$PWD/src/leveldb/libleveldb.a; cd $$PWD/src/leveldb ; $(MAKE) clean
} else {
    message(Building with Berkeley DB transaction index)
    SOURCES += src/txdb-bdb.cpp
}


# use: qmake "USE_ASM=1"
contains(USE_ASM, 1) {
    message(Using assembler scrypt & sha256 implementations)
    DEFINES += USE_ASM

     contains(QMAKE_TARGET.arch, i386) | contains(QMAKE_TARGET.arch, i586) | contains(QMAKE_TARGET.arch, i686) {
        message("x86 platform, setting -msse2 & -mssse3 flags")

        QMAKE_CXXFLAGS += -msse2 -mssse3
        QMAKE_CFLAGS += -msse2 -mssse3
    }

    contains(QMAKE_TARGET.arch, x86_64) | contains(QMAKE_TARGET.arch, amd64) {
        message("x86_64 platform, setting -mssse3 flag")

        QMAKE_CXXFLAGS += -mssse3
        QMAKE_CFLAGS += -mssse3
    }


    SOURCES += src/crypto/scrypt/asm/scrypt-arm.S src/crypto/scrypt/asm/scrypt-x86.S src/crypto/scrypt/asm/scrypt-x86_64.S src/crypto/scrypt/asm/asm-wrapper.cpp
    SOURCES += src/crypto/sha2/asm/sha2-arm.S src/crypto/sha2/asm/sha2-x86.S src/crypto/sha2/asm/sha2-x86_64.S
} else {
    # use: qmake "USE_SSE2=1"
    contains(USE_SSE2, 1) {
        message(Using SSE2 intrinsic scrypt implementation & generic sha256 implementation)
        SOURCES += src/crypto/scrypt/intrin/scrypt-sse2.cpp
        DEFINES += USE_SSE2
        QMAKE_CXXFLAGS += -msse2 
        QMAKE_CFLAGS += -msse2
    } else {
        message(Using generic scrypt & sha256 implementations)
        SOURCES += src/crypto/scrypt/generic/scrypt-generic.cpp
    }
}

# regenerate src/build.h
!windows|contains(USE_BUILD_INFO, 1) {
    genbuild.depends = FORCE
    genbuild.commands = cd $$PWD; /bin/sh share/genbuild.sh $$OUT_PWD/build/build.h
    genbuild.target = $$OUT_PWD/build/build.h
    PRE_TARGETDEPS += $$OUT_PWD/build/build.h
    QMAKE_EXTRA_TARGETS += genbuild
    DEFINES += HAVE_BUILD_INFO
}

contains(USE_O3, 1) {
    message(Building O3 optimization flag)
    QMAKE_CXXFLAGS_RELEASE -= -O2
    QMAKE_CFLAGS_RELEASE -= -O2
    QMAKE_CXXFLAGS += -O3
    QMAKE_CFLAGS += -O3
}


# QMAKE_CXXFLAGS_WARN_ON = -fdiagnostics-show-option -Wall -Wextra -Wno-ignored-qualifiers -Wformat -Wformat-security -Wno-unused-parameter -Wno-unused-local-typedef -Wstack-protector

# Input
DEPENDPATH += src src/json src/qt
HEADERS += src/qt/bitcoingui.h \
    src/qt/intro.h \
    src/qt/transactiontablemodel.h \
    src/qt/addresstablemodel.h \
    src/qt/optionsdialog.h \
    src/qt/coincontroldialog.h \
    src/qt/coincontroltreewidget.h \
    src/qt/sendcoinsdialog.h \
    src/qt/addressbookpage.h \
    src/qt/signverifymessagedialog.h \
    src/qt/aboutdialog.h \
    src/qt/editaddressdialog.h \
    src/qt/bitcoinaddressvalidator.h \
    src/qt/mintingfilterproxy.h \
    src/qt/mintingtablemodel.h \
    src/qt/mintingview.h \
    src/kernelrecord.h \
    src/alert.h \
    src/addrman.h \
    src/base58.h \
    src/bignum.h \
    src/checkpoints.h \
    src/compat.h \
    src/coincontrol.h \
    src/sync.h \
    src/util.h \
    src/timestamps.h \
    src/hash.h \
    src/uint256.h \
    src/kernel.h \
    src/kernel_worker.h \
    src/scrypt.h \
    src/serialize.h \
    src/main.h \
    src/miner.h \
    src/net.h \
    src/ministun.h \
    src/key.h \
    src/db.h \
    src/txdb.h \
    src/walletdb.h \
    src/script.h \
    src/init.h \
    src/irc.h \
    src/mruset.h \
    src/json/json_spirit_writer_template.h \
    src/json/json_spirit_writer.h \
    src/json/json_spirit_value.h \
    src/json/json_spirit_utils.h \
    src/json/json_spirit_stream_reader.h \
    src/json/json_spirit_reader_template.h \
    src/json/json_spirit_reader.h \
    src/json/json_spirit_error_position.h \
    src/json/json_spirit.h \
    src/qt/clientmodel.h \
    src/qt/guiutil.h \
    src/qt/transactionrecord.h \
    src/qt/guiconstants.h \
    src/qt/optionsmodel.h \
    src/qt/monitoreddatamapper.h \
    src/qt/transactiondesc.h \
    src/qt/transactiondescdialog.h \
    src/qt/bitcoinamountfield.h \
    src/wallet.h \
    src/keystore.h \
    src/qt/transactionfilterproxy.h \
    src/qt/transactionview.h \
    src/qt/walletmodel.h \
    src/bitcoinrpc.h \
    src/qt/overviewpage.h \
    src/qt/csvmodelwriter.h \
    src/crypter.h \
    src/qt/sendcoinsentry.h \
    src/qt/qvalidatedlineedit.h \
    src/qt/bitcoinunits.h \
    src/qt/qvaluecombobox.h \
    src/qt/askpassphrasedialog.h \
    src/qt/trafficgraphwidget.h \
    src/protocol.h \
    src/qt/notificator.h \
    src/qt/qtipcserver.h \
    src/allocators.h \
    src/ui_interface.h \
    src/qt/rpcconsole.h \
    src/version.h \
    src/ntp.h \
    src/netbase.h \
    src/clientversion.h \
    src/qt/multisigaddressentry.h \
    src/qt/multisiginputentry.h \
    src/qt/multisigdialog.h \
    src/qt/secondauthdialog.h \
    src/qt/qrcodedialog.h

SOURCES += src/qt/bitcoin.cpp src/qt/bitcoingui.cpp \
    src/qt/intro.cpp \
    src/qt/transactiontablemodel.cpp \
    src/qt/addresstablemodel.cpp \
    src/qt/optionsdialog.cpp \
    src/qt/sendcoinsdialog.cpp \
    src/qt/coincontroldialog.cpp \
    src/qt/coincontroltreewidget.cpp \
    src/qt/addressbookpage.cpp \
    src/qt/signverifymessagedialog.cpp \
    src/qt/aboutdialog.cpp \
    src/qt/editaddressdialog.cpp \
    src/qt/bitcoinaddressvalidator.cpp \
    src/qt/trafficgraphwidget.cpp \
    src/qt/mintingfilterproxy.cpp \
    src/qt/mintingtablemodel.cpp \
    src/qt/mintingview.cpp \
    src/kernelrecord.cpp \
    src/alert.cpp \
    src/version.cpp \
    src/sync.cpp \
    src/util.cpp \
    src/netbase.cpp \
    src/ntp.cpp \
    src/key.cpp \
    src/script.cpp \
    src/main.cpp \
    src/miner.cpp \
    src/init.cpp \
    src/net.cpp \
    src/stun.cpp \
    src/irc.cpp \
    src/checkpoints.cpp \
    src/addrman.cpp \
    src/db.cpp \
    src/walletdb.cpp \
    src/qt/clientmodel.cpp \
    src/qt/guiutil.cpp \
    src/qt/transactionrecord.cpp \
    src/qt/optionsmodel.cpp \
    src/qt/monitoreddatamapper.cpp \
    src/qt/transactiondesc.cpp \
    src/qt/transactiondescdialog.cpp \
    src/qt/bitcoinstrings.cpp \
    src/qt/bitcoinamountfield.cpp \
    src/wallet.cpp \
    src/keystore.cpp \
    src/qt/transactionfilterproxy.cpp \
    src/qt/transactionview.cpp \
    src/qt/walletmodel.cpp \
    src/bitcoinrpc.cpp \
    src/rpcdump.cpp \
    src/rpcnet.cpp \
    src/rpcmining.cpp \
    src/rpcwallet.cpp \
    src/rpcblockchain.cpp \
    src/rpcrawtransaction.cpp \
    src/qt/overviewpage.cpp \
    src/qt/csvmodelwriter.cpp \
    src/crypter.cpp \
    src/qt/sendcoinsentry.cpp \
    src/qt/qvalidatedlineedit.cpp \
    src/qt/bitcoinunits.cpp \
    src/qt/qvaluecombobox.cpp \
    src/qt/askpassphrasedialog.cpp \
    src/protocol.cpp \
    src/qt/notificator.cpp \
    src/qt/qtipcserver.cpp \
    src/qt/rpcconsole.cpp \
    src/noui.cpp \
    src/kernel.cpp \
    src/kernel_worker.cpp \
    src/qt/multisigaddressentry.cpp \
    src/qt/multisiginputentry.cpp \
    src/qt/multisigdialog.cpp \
    src/qt/secondauthdialog.cpp \
    src/qt/qrcodedialog.cpp \
    src/base58.cpp

RESOURCES += \
    src/qt/bitcoin.qrc

FORMS += \
    src/qt/forms/intro.ui \
    src/qt/forms/coincontroldialog.ui \
    src/qt/forms/sendcoinsdialog.ui \
    src/qt/forms/addressbookpage.ui \
    src/qt/forms/signverifymessagedialog.ui \
    src/qt/forms/aboutdialog.ui \
    src/qt/forms/editaddressdialog.ui \
    src/qt/forms/transactiondescdialog.ui \
    src/qt/forms/overviewpage.ui \
    src/qt/forms/sendcoinsentry.ui \
    src/qt/forms/askpassphrasedialog.ui \
    src/qt/forms/rpcconsole.ui \
    src/qt/forms/optionsdialog.ui \
    src/qt/forms/multisigaddressentry.ui \
    src/qt/forms/multisiginputentry.ui \
    src/qt/forms/multisigdialog.ui \
    src/qt/forms/secondauthdialog.ui \
    src/qt/forms/qrcodedialog.ui

CODECFORTR = UTF-8

# for lrelease/lupdate
# also add new translations to src/qt/bitcoin.qrc under translations/
TRANSLATIONS = $$files(src/qt/locale/bitcoin_*.ts)

isEmpty(QMAKE_LRELEASE) {
    win32:QMAKE_LRELEASE = $$[QT_INSTALL_BINS]\\lrelease.exe
    else:QMAKE_LRELEASE = $$[QT_INSTALL_BINS]/lrelease
}
isEmpty(QM_DIR):QM_DIR = $$PWD/src/qt/locale
# automatically build translations, so they can be included in resource file
TSQM.name = lrelease ${QMAKE_FILE_IN}
TSQM.input = TRANSLATIONS
TSQM.output = $$QM_DIR/${QMAKE_FILE_BASE}.qm
TSQM.commands = $$QMAKE_LRELEASE ${QMAKE_FILE_IN} -qm ${QMAKE_FILE_OUT}
TSQM.CONFIG = no_link
QMAKE_EXTRA_COMPILERS += TSQM

# "Other files" to show in Qt Creator
OTHER_FILES += \
    doc/*.rst doc/*.txt doc/README README.md res/bitcoin-qt.rc

# platform specific defaults, if not overridden on command line

isEmpty(BOOST_LIB_SUFFIX) {
    BOOST_THREAD_LIB_SUFFIX = $$BOOST_LIB_SUFFIX
    macx:BOOST_THREAD_LIB_SUFFIX=-mt
    win32: {
        BOOST_LIB_SUFFIX = -vc141-mt-x32-1_66
    }
    win64: {
        BOOST_LIB_SUFFIX = -vc141-mt-x64-1_66
    }
}

isEmpty(BDB_LIB_PATH) {
    macx:BDB_LIB_PATH=/usr/local/opt/berkeley-db@4/lib
    windows:BDB_LIB_PATH=$$PWD/MSVC/db-4.8.30.NC/build_windows/Win32/Release/
}

isEmpty(OPENSSL_LIB_PATH) {
    macx:OPENSSL_LIB_PATH = /usr/local/opt/openssl/lib
    windows:OPENSSL_LIB_PATH=$$PWD/MSVC/openssl-1.0.2l-vs2017/lib
}

isEmpty(BDB_LIB_SUFFIX) {
    macx:BDB_LIB_SUFFIX = -4.8
    windows:BDB_LIB_SUFFIX = 48
}

isEmpty(BDB_INCLUDE_PATH) {
    macx:BDB_INCLUDE_PATH=/usr/local/opt/berkeley-db@4/include
    windows:BDB_INCLUDE_PATH=$$PWD/MSVC/db-4.8.30.NC/build_windows
}

isEmpty(OPENSSL_INCLUDE_PATH) {
    macx:OPENSSL_INCLUDE_PATH=/usr/local/opt/openssl/include
    windows:OPENSSL_INCLUDE_PATH=$$PWD/MSVC/openssl-1.0.2l-vs2017/include
}

isEmpty(BOOST_LIB_PATH) {
    macx:BOOST_LIB_PATH=/usr/local/opt/boost/lib
    windows:BOOST_LIB_PATH=$$PWD/MSVC/boost_1_66_0/lib32-msvc-14.1
}

isEmpty(OPENSSL_LIB_SUFFIX) {
    windows:OPENSSL_LIB_SUFFIX=MT
}

isEmpty(BOOST_INCLUDE_PATH) {
    macx:BOOST_INCLUDE_PATH=/usr/local/opt/boost/include
    windows:BOOST_INCLUDE_PATH=$$PWD/MSVC/boost_1_66_0
}

isEmpty(MINIUPNPC_INCLUDE_PATH) {
    macx:MINIUPNPC_INCLUDE_PATH=/usr/local/opt/miniupnpc/include
    windows:MINIUPNPC_INCLUDE_PATH=$$PWD/MSVC # TODO
}

isEmpty(MINIUPNPC_LIB_PATH) {
    macx:MINIUPNPC_LIB_PATH=/usr/local/opt/miniupnpc/lib
    windows:MINIUPNPC_LIB_PATH=$$PWD/MSVC # TODO
}

isEmpty(QRENCODE_INCLUDE_PATH) {
    macx:QRENCODE_INCLUDE_PATH=/usr/local/opt/qrencode/include
    windows:QRENCODE_INCLUDE_PATH=$$PWD/MSVC/libqrencode
}

isEmpty(QRENCODE_LIB_PATH) {
    macx:QRENCODE_LIB_PATH=/usr/local/opt/qrencode/lib
    windows:QRENCODE_LIB_PATH=$$PWD/MSVC/libqrencode/Release/Release
}

INCLUDEPATH += $$BOOST_INCLUDE_PATH $$BDB_INCLUDE_PATH $$OPENSSL_INCLUDE_PATH $$QRENCODE_INCLUDE_PATH
LIBS += $$join(BOOST_LIB_PATH,,-L,) $$join(BDB_LIB_PATH,,-L,) $$join(OPENSSL_LIB_PATH,,-L,) $$join(QRENCODE_LIB_PATH,,-L,)
!windows: {
    LIBS += -lssl -lcrypto
    LIBS += -ldb_cxx$$BDB_LIB_SUFFIX
    LIBS += -lqrencode
    LIBS += -lboost_system$$BOOST_LIB_SUFFIX -lboost_filesystem$$BOOST_LIB_SUFFIX -lboost_program_options$$BOOST_LIB_SUFFIX -lboost_thread$$BOOST_THREAD_LIB_SUFFIX
}
windows: {
    LIBS += -lssleay32$$OPENSSL_LIB_SUFFIX -llibeay32$$OPENSSL_LIB_SUFFIX -luser32
    LIBS += -llibdb_stl$$BDB_LIB_SUFFIX -llibdb$$BDB_LIB_SUFFIX
    LIBS += -lqrencode 
    LIBS += -llibboost_system$$BOOST_LIB_SUFFIX -llibboost_filesystem$$BOOST_LIB_SUFFIX -llibboost_program_options$$BOOST_LIB_SUFFIX -llibboost_thread$$BOOST_LIB_SUFFIX
}
windows:LIBS += -lws2_32 -lshlwapi -lmswsock -lole32 -loleaut32 -luuid -lgdi32
windows:LIBS += -lshlwapi
windows:LIBS += -lws2_32 -lole32 -loleaut32 -luuid -lgdi32
windows:DEFINES += WIN32
windows:RC_FILE = src/qt/res/bitcoin-qt.rc

!windows:!macx {
    DEFINES += LINUX
    LIBS += -lrt
}

macx:HEADERS += src/qt/macdockiconhandler.h \
                src/qt/macnotificationhandler.h
macx:OBJECTIVE_SOURCES += src/qt/macdockiconhandler.mm \
                          src/qt/macnotificationhandler.mm
macx:LIBS += -framework Foundation -framework ApplicationServices -framework AppKit
macx:DEFINES += MAC_OSX MSG_NOSIGNAL=0
macx:ICON = src/qt/res/icons/bitcoin.icns
macx:TARGET = "XP-Qt"
macx:QMAKE_CFLAGS_THREAD += -lpthread
macx:QMAKE_LFLAGS_THREAD += -lpthread
macx:QMAKE_CXXFLAGS_THREAD += -lpthread

contains(RELEASE, 1) {
    !windows:!macx {
        # Linux: turn dynamic linking back on for c/c++ runtime libraries
        LIBS += -Wl,-Bdynamic
    }
}

linux-* {
    # We may need some linuxism here
    LIBS += -ldl
}

netbsd-*|freebsd-*|openbsd-* {
    # libexecinfo is required for back trace
    LIBS += -lexecinfo
}

system($$QMAKE_LRELEASE -silent $$PWD/src/qt/locale/translations.pro)
