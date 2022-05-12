#!/bin/bash
set -xe

_PKG=icu4c-67_1
_PREFIX="$1"
_SCRATCH_DIR="$2"

if [[ ! -x "$_PREFIX/bin/icu-config" ]]
then
  cd "$_SCRATCH_DIR"
  echo "94a80cd6f251a53bd2a997f6f1b5ac6653fe791dfab66e1eb0227740fb86d5dc *$_PKG-src.tgz" | shasum -cs || \
    curl -OkSL "https://github.com/unicode-org/icu/releases/download/release-${_PKG:6:2}-${_PKG:9}/$_PKG-src.tgz"
  rm -rf icu
  tar -xf "$_PKG-src.tgz"

  cd icu/source
  # Patch U_ASSERT C++14 compatibility
  sed -i- 's/^\(#   define U_ASSERT(exp) \)void()/\1(void)0/' common/uassert.h

  PKG_CONFIG=/usr/bin/false \
  ./configure --with-library-bits=64 --disable-shared --enable-static "--prefix=$_PREFIX" \
    --disable-tests --disable-samples --disable-extras --disable-icuio

  # Build lib only
  sed -i- -e 's/^\(install:\).*/\1/;s/\$(SUBDIRS)/toolutil icupkg pkgdata/' tools/Makefile
  make -j2 VERBOSE=1
  make install
fi
