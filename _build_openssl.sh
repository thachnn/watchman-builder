#!/bin/bash
set -xe

_PKG=openssl-0.9.8zh
_PREFIX="$1"
_SCRATCH_DIR="$2"

if [[ ! -e "$_PREFIX/lib/libcrypto.a" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tar.gz" ]] || curl -OkSL "https://ftp.openssl.org/source/$_PKG.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tar.gz"

  cd "$_PKG"
  perl Configure darwin64-x86_64-cc no-shared "--prefix=$_PREFIX"

  # Build lib only
  sed -i- 's/^\(DIRS *=.*\) apps test tools$/\1/' Makefile
  make -j2
  make install_sw
fi
