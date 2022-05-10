#!/bin/bash
set -xe

_PKG=openssl-1.1.1i
_PREFIX="$1"
_SCRATCH_DIR="$2"

if [[ ! -e "$_PREFIX/lib/libcrypto.a" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tar.gz" ]] || curl -OkSL "https://ftp.openssl.org/source/$_PKG.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tar.gz"

  cd "$_PKG"
  perl Configure darwin64-x86_64-cc no-shared "--prefix=$_PREFIX" \
    enable-ec_nistp_64_gcc_128 no-tests
  # TODO: enable-ec_nistp_64_gcc_128 may not needle

  # Build lib only
  sed -i- 's,^LIBS=apps/libapps\.a ,LIBS=,' Makefile
  make -j2 install_dev install_engines
fi
