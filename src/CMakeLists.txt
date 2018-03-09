# ----------------------------------------------------------------------------
# Root CMake file for simon and speck
# ----------------------------------------------------------------------------

cmake_minimum_required(VERSION 3.7)

project(XPd CXX C)

# ----------------------------------------------------------------------------
# XPd options
# ----------------------------------------------------------------------------
option(USE_IPV6    "use IPV6" YES)
option(USE_LEVELDB "use leveldb" NO)
option(USE_ASM     "use ASM" NO)
option(USE_SSE2    "use SSE2" NO)
if(MSVC)
  set(DEFAULT_STATIC_OPTION YES)
else()
  set(DEFAULT_STATIC_OPTION NO)
endif()
option(ENABLE_STATIC "static link" ${DEFAULT_STATIC_OPTION})

# ----------------------------------------------------------------------------
# detect compiler and target platform architecture
# ----------------------------------------------------------------------------

# Add these standard paths to the search paths for FIND_PATH
# to find include files from these locations first
if(MINGW)
    if(EXISTS /mingw)
        list(APPEND CMAKE_INCLUDE_PATH /mingw)
    endif()
    if(EXISTS /mingw32)
        list(APPEND CMAKE_INCLUDE_PATH /mingw32)
    endif()
    if(EXISTS /mingw64)
        list(APPEND CMAKE_INCLUDE_PATH /mingw64)
    endif()
endif()


# ----------------------------------------------------------------------------
#  Detect endianness of build platform
# ----------------------------------------------------------------------------

if(IOS)
  # test_big_endian needs try_compile, which doesn't work for iOS
  # http://public.kitware.com/Bug/view.php?id=12288
  set(WORDS_BIGENDIAN 0)
else()
  include(TestBigEndian)
  test_big_endian(WORDS_BIGENDIAN)
endif()

if(APPLE AND (${CMAKE_SYSTEM_NAME} MATCHES "Darwin"))
  set(DEPSDIR "/usr/local/opt") # homebrew prefix
elseif(MSVC)
  set(DEPSDIR "${CMAKE_SOURCE_DIR}/../MSVC")
endif()

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "" FORCE)
endif()

# include directories
include_directories(${CMAKE_SOURCE_DIR})
## openssl
if (DEFINED $ENV{OPENSSL_INCLUDE_PATH})
  include_directories($ENV{OPENSSL_INCLUDE_PATH)
else()
  if(APPLE AND (${CMAKE_SYSTEM_NAME} MATCHES "Darwin"))
    include_directories(${DEPSDIR}/openssl/include)
  elseif(MSVC)
    include_directories(${DEPSDIR}/openssl-1.0.2l-vs2017/include)
  endif()
endif()

## boost
if (DEFINED $ENV{BOOST_INCLUDE_PATH})
  include_directories($ENV{BOOST_INCLUDE_PATH})
else()
  if(APPLE AND (${CMAKE_SYSTEM_NAME} MATCHES "Darwin"))
    include_directories(${DEPSDIR}/boost/include)
  elseif(MSVC)
    include_directories(${DEPSDIR}/boost_1_66_0)
  endif()
endif()

## berkeley db
if (DEFINED $ENV{BDB_INCLUDE_PATH})
  include_directories($ENV{BDB_INCLUDE_PATH})
else()
  if(APPLE AND (${CMAKE_SYSTEM_NAME} MATCHES "Darwin"))
    include_directories(${DEPSDIR}/berkeley-db@4/include)
  elseif(MSVC)
    include_directories(${DEPSDIR}/db-4.8.30.NC/build_windows)
  endif()
endif()

# library directories
## openssl
if (DEFINED $ENV{OPENSSL_LIB_PATH})
  set(OPENSSL_LIB_PATH $ENV{OPENSSL_LIB_PATH})
else()
  if(APPLE AND (${CMAKE_SYSTEM_NAME} MATCHES "Darwin"))
    set(OPENSSL_LIB_PATH ${DEPSDIR}/openssl/lib)
  elseif(MSVC)
    set(OPENSSL_LIB_PATH ${DEPSDIR}/openssl-1.0.2l-vs2017/lib)
  endif()
endif()
link_directories(${OPENSSL_LIB_PATH})
if(MSVC AND ENABLE_STATIC)
  if(CMAKE_BUILD_TYPE MATCHES Release)
    set(OPENSSL_LIB_SUFFIX MT)
  else()
    set(OPENSSL_LIB_SUFFIX MTd)
  endif()
else()
  # TODO: 
endif()

## boost
if (DEFINED $ENV{BOOST_LIB_PATH})
  set(BOOST_LIB_PATH $ENV{BOOST_LIB_PATH})
else()
  if(APPLE AND (${CMAKE_SYSTEM_NAME} MATCHES "Darwin"))
    set(BOOST_LIB_PATH ${DEPSDIR}/boost/lib)
  else(MSVC)
    # TODO: change msvc version
    if(WIN32)
      set(BOOST_LIB_PATH ${DEPSDIR}/boost_1_66_0/lib32-msvc-14.1)
      set(BOOST_LIB_ARCH x32)
    else()
      # don't consider ARM yet.
      set(BOOST_LIB_PATH ${DEPSDIR}/boost_1_66_0/lib64-msvc-14.1)
      set(BOOST_LIB_ARCH x64)
    endif()
  endif()
endif()
link_directories(${BOOST_LIB_PATH})
if(MSVC AND ENABLE_STATIC)
  # TODO: change msvc version
  if(CMAKE_BUILD_TYPE MATCHES Release)
    set(BOOST_LIB_SUFFIX vc141-mt-${BOOST_LIB_ARCH}-1_66)
  else()
    set(BOOST_LIB_SUFFIX vc141-mt-gd-${BOOST_LIB_ARCH}-1_66)
  endif()
else()
  # TODO:
endif()

## berkeley db
if (DEFINED $ENV{BDB_LIB_PATH})
  set(BDB_LIB_PATH $ENV{BDB_LIB_PATH})
else()
  if(APPLE AND (${CMAKE_SYSTEM_NAME} MATCHES "Darwin"))
    set(BDB_LIB_PATH ${DEPSDIR}/berkeley-db@4/lib)
  elseif(MSVC)
    # TODO: 4.8.30 not support windows 64...
    if(WIN32)
      if(CMAKE_BUILD_TYPE MATCHES Release)
        set(BDB_LIB_PATH ${DEPSDIR}/db-4.8.30.NC/build_windows/Win32/Release)
      else()
        set(BDB_LIB_PATH ${DEPSDIR}/db-4.8.30.NC/build_windows/Win32/Debug)
      endif()
    endif()
  endif()
endif()
link_directories(${BDB_LIB_PATH})
if(MSVC AND ENABLE_STATIC)
  if(CMAKE_BUILD_TYPE MATCHES Release)
    set(BDB_LIB_SUFFIX "")
  else()
    set(BDB_LIB_SUFFIX d)
  endif()
else()
  # TODO:
endif()


#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_C_STANDARD 11)

set(XPd_SRCS
  alert.cpp
  version.cpp
  checkpoints.cpp
  netbase.cpp
  addrman.cpp
  crypter.cpp
  base58.cpp
  key.cpp
  db.cpp
  init.cpp
  irc.cpp
  keystore.cpp
  main.cpp
  miner.cpp
  net.cpp
  ntp.cpp
  stun.cpp
  protocol.cpp
  bitcoinrpc.cpp
  rpcdump.cpp
  rpcnet.cpp
  rpcmining.cpp
  rpcwallet.cpp
  rpcblockchain.cpp
  rpcrawtransaction.cpp
  script.cpp
  sync.cpp
  util.cpp
  wallet.cpp
  walletdb.cpp
  noui.cpp
  kernel.cpp
  kernelrecord.cpp
  kernel_worker.cpp
)

if(USE_LEVELDB)
  # TODO: impl
  # set(XPd_SRCS ${XPd_SRCS} txdb-leveldb.cpp)
  # include_directories(${CMAKE_SOURCE_DIR}/leveldb/include)
  # include_directories(${CMAKE_SOURCE_DIR}/leveldb/helpers)
else()
  set(XPd_SRCS ${XPd_SRCS} txdb-bdb.cpp)
endif()

if(USE_ASM)
  # TODO: impl
  # enable_language(ASM)
  # add_definitions(-DUSE_ASM)
else()
  if(USE_SSE2)
    # TODO: impl
    #
  else()
    set(XPd_SRCS ${XPd_SRCS} crypto/scrypt/generic/scrypt-generic.cpp)
  endif()
endif()

add_definitions(-DUSE_IPV6=${USE_IPV6})
if(APPLE AND (${CMAKE_SYSTEM_NAME} MATCHES "Darwin"))
  add_definitions(-DMAC_OSX)
  add_definitions(-DMSG_NOSIGNAL=0)
  add_definitions(-DBOOST_SPIRIT_THREADSAFE)
  add_definitions(-D__STDC_FORMAT_MACROS)
  add_definitions(-D__STDC_LIMIT_MACROS)
elseif((WIN32 OR WIN64) AND MSVC)
  add_definitions(/DWIN32)
  add_definitions(/D_WINDOWS)
  add_definitions(/DBOOST_THREAD_USE_LIB)
  add_definitions(/DBOOST_SPIRIT_THREADSAFE)
  add_definitions(/D__STDC_FORMAT_MACROS)
  add_definitions(/D__STDC_LIMIT_MACROS)
endif()

if(MSVC)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /EHsc")
  set(CMAKE_C_FLAGS "${CMAKE_CXX_FLAGS} /EHsc")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /arch:SSE2")
  set(CMAKE_C_FLAGS "${CMAKE_CXX_FLAGS} /arch:SSE2")
else()
  set(CMAKE_C_FLAGS "-msse2 -msse3")
  set(CMAKE_CXX_FLAGS "-msse2 -msse3")
endif()

# build
file(REMOVE ${CMAKE_SOURCE_DIR}/build.h)
execute_process(
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  COMMAND git log -n1 --format=%ci
  OUTPUT_VARIABLE COMMITDATE
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  COMMAND cmake -E echo "#define BUILD_DATE \"${COMMITDATE}\""
  OUTPUT_VARIABLE COMMITDATE_DEFINE
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
file(WRITE ${CMAKE_SOURCE_DIR}/build.h ${COMMITDATE_DEFINE})
if(MSVC)
  add_definitions(/DHAVE_BUILD_INFO)
else()
  add_definitions(-DHAVE_BUILD_INFO)
endif()

add_executable(XPd ${XPd_SRCS})
if(ENABLE_STATIC)
  message(status hoge)
  if (MSVC)
    set(CMAKE_FIND_LIBRARY_SUFFIXES ".lib")
  elseif (UNIX)
    set(CMAKE_FIND_LIBRARY_SUFFIXES ".a")
  endif()

  if(MSVC)
    target_link_libraries(XPd
     ${BDB_LIB_PATH}/libdb_stl48${BDB_LIB_SUFFIX}${CMAKE_FIND_LIBRARY_SUFFIXES}
     ${BDB_LIB_PATH}/libdb48${BDB_LIB_SUFFIX}${CMAKE_FIND_LIBRARY_SUFFIXES}
     ${BOOST_LIB_PATH}/libboost_system-${BOOST_LIB_SUFFIX}${CMAKE_FIND_LIBRARY_SUFFIXES}
     ${BOOST_LIB_PATH}/libboost_filesystem-${BOOST_LIB_SUFFIX}${CMAKE_FIND_LIBRARY_SUFFIXES}
     ${BOOST_LIB_PATH}/libboost_program_options-${BOOST_LIB_SUFFIX}${CMAKE_FIND_LIBRARY_SUFFIXES}
     ${BOOST_LIB_PATH}/libboost_thread-${BOOST_LIB_SUFFIX}${CMAKE_FIND_LIBRARY_SUFFIXES}
     ${OPENSSL_LIB_PATH}/ssleay32${OPENSSL_LIB_SUFFIX}${CMAKE_FIND_LIBRARY_SUFFIXES}
     ${OPENSSL_LIB_PATH}/libeay32${OPENSSL_LIB_SUFFIX}${CMAKE_FIND_LIBRARY_SUFFIXES}
   )
  else()
    target_link_libraries(XPd
     ${BDB_LIB_PATH}/libdb_cxx-4.8${CMAKE_FIND_LIBRARY_SUFFIXES}
     ${BOOST_LIB_PATH}/libboost_system-mt${CMAKE_FIND_LIBRARY_SUFFIXES}
     ${BOOST_LIB_PATH}/libboost_filesystem-mt${CMAKE_FIND_LIBRARY_SUFFIXES}
     ${BOOST_LIB_PATH}/libboost_program_options-mt${CMAKE_FIND_LIBRARY_SUFFIXES}
     ${BOOST_LIB_PATH}/libboost_thread-mt${CMAKE_FIND_LIBRARY_SUFFIXES}
     ${OPENSSL_LIB_PATH}/libssl${CMAKE_FIND_LIBRARY_SUFFIXES}
     ${OPENSSL_LIB_PATH}/libcrypto${CMAKE_FIND_LIBRARY_SUFFIXES}
     z
   )

  endif()
else()
  target_link_libraries(XPd
    db_cxx-4.8
    boost_system-mt
    boost_filesystem-mt
    boost_program_options-mt
    boost_thread-mt
    ssl
    crypto
    z
    )
  endif()
