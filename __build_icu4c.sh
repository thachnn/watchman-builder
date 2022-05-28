#!/bin/bash
set -xe

_PKG=icu4c-64_2
_PREFIX="$1"
_SCRATCH_DIR="$2"

if [[ ! -x "$_PREFIX/bin/icu-config" ]]
then
  cd "$_SCRATCH_DIR"
  while ! shasum -cs <<< "627d5d8478e6d96fc8c90fed4851239079a561a6a8b9e48b0892f24e82d31d6c *$_PKG-src.tgz"
  do
    curl -OkfSL "https://github.com/unicode-org/icu/releases/download/release-${_PKG:6:2}-${_PKG:9}/$_PKG-src.tgz"
  done
  rm -rf icu
  tar -xf "$_PKG-src.tgz"

  cd icu/source
  PKG_CONFIG=/usr/bin/false \
  ./configure --with-library-bits=64 --disable-shared --enable-static "--prefix=$_PREFIX" \
    --disable-tests --disable-samples --disable-extras --disable-icuio

  # Build lib only
  sed -i- -e 's/^\(install:\).*/\1/;s/\$(SUBDIRS)/toolutil icupkg pkgdata/' tools/Makefile
  make -j2 VERBOSE=1
  make install
fi
