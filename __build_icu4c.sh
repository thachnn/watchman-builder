#!/bin/bash
set -xe

_VER=70_1
_PKG="icu4c-$_VER"
_PREFIX="$1"
_SCRATCH_DIR="$2"
_NO_TESTS="$3"

if [[ ! -x "$_PREFIX/bin/icu-config" ]]
then
  cd "$_SCRATCH_DIR"
  while ! shasum -cs <<< "8d205428c17bf13bb535300669ed28b338a157b1c01ae66d31d0d3e2d47c3fd5 *$_PKG-src.tgz"
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
