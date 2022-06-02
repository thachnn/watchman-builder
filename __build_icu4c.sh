#!/bin/bash
set -xe

_VER=64_2
_PKG="icu4c-$_VER"
_PREFIX="$1"
_SCRATCH_DIR="$2"
_NO_TESTS="$3"

if [[ ! -x "$_PREFIX/bin/icu-config" ]]
then
  cd "$_SCRATCH_DIR"
  while ! shasum -cs <<< "627d5d8478e6d96fc8c90fed4851239079a561a6a8b9e48b0892f24e82d31d6c *$_PKG-src.tgz"
  do
    curl -OkfSL "https://github.com/unicode-org/icu/releases/download/release-${_VER//_/-}/$_PKG-src.tgz"
  done
  rm -rf icu
  tar -xf "$_PKG-src.tgz"

  cd icu/source
  PKG_CONFIG=/usr/bin/false \
  ./configure --with-library-bits=64 --disable-shared --enable-static "--prefix=$_PREFIX" \
    --disable-samples --disable-extras --disable-icuio $([[ "$_NO_TESTS" == 0 ]] || echo --disable-tests)

  # Build lib only
  _tools="toolutil $([[ "$_NO_TESTS" != 0 ]] || echo -n ctestfw) icupkg pkgdata"
  sed -i- -e 's/^\(install:\).*/\1/' -e "s/\\\$(SUBDIRS)/$_tools/" tools/Makefile

  make -j2 VERBOSE=1
  make install

  if [[ "$_NO_TESTS" == 0 ]]; then
    sed -i- 's/^\(TESTDATA *=\).*/\1/' test/Makefile
    make check || true
  fi
fi
