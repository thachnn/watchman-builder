#!/bin/bash
set -xe

_PKG=openssl-1.1.1l
_PREFIX="$1"
_SCRATCH_DIR="$2"

if [[ ! -e "$_PREFIX/include/openssl" ]]
then
  cd "$_SCRATCH_DIR"
  while ! shasum -cs <<< "0b7a3e5e59c34827fe0c3a74b7ec8baef302b98fa80088d7f9153aa16fa76bd1 *$_PKG.tar.gz"
  do
    curl -OkfSL "https://ftp.openssl.org/source/$_PKG.tar.gz"
  done
  rm -rf "$_PKG"
  tar -xf "$_PKG.tar.gz"

  cd "$_PKG"
  # Fix CommonRandom.h error on CLT 9.x
  sed -i '' $'s|^\\(# *include <CommonCrypto/Common\\)Random.h>|\\1CryptoError.h>\\\n&|' \
    crypto/rand/rand_unix.c

  # enable-ec_nistp_64_gcc_128
  perl Configure darwin64-x86_64-cc "--prefix=$_PREFIX" no-shared \
    enable-static-engine no-tests

  # Build lib only
  sed -i- 's,^LIBS=apps/libapps\.a ,LIBS=,' Makefile
  make -j2 install_dev install_engines
fi
