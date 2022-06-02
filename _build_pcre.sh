#!/bin/bash
set -xe

_PKG=pcre-8.44
_PREFIX="$1"
_SCRATCH_DIR="$2"
_NO_TESTS="$3"

if [[ ! -x "$_PREFIX/bin/pcre-config" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tar.bz2" ]] || curl -OkfSL "https://ftp.exim.org/pub/pcre/$_PKG.tar.bz2"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tar.bz2"

  cd "$_PKG"
  ./configure --disable-dependency-tracking --enable-unicode-properties --enable-utf8 \
    --enable-jit --disable-shared "--prefix=$_PREFIX" CFLAGS=-O2

  # Build lib only
  sed -i- -e 's/^\(PROGRAMS *=\).*/\1/;s/^\(MANS *=\).*/\1/' \
    -e 's/ RunTest / /;s/= *RunGrepTest$/=/' Makefile

  make -j2 V=1
  make install-binSCRIPTS install-libLTLIBRARIES \
    install-includeHEADERS install-nodist_includeHEADERS install-pkgconfigDATA

  [[ "$_NO_TESTS" != 0 ]] || make check
fi
