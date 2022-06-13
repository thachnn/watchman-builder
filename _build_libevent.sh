#!/bin/bash
set -xe

_PKG=libevent-2.1.12-stable
_PREFIX="$1"
_SCRATCH_DIR="$2"
_NO_TESTS="$3"

if [[ ! -e "$_PREFIX/lib/libevent.a" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tar.gz" ]] || \
    curl -OkfSL "https://github.com/libevent/libevent/releases/download/release-${_PKG#*-}/$_PKG.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tar.gz"

  cd "$_PKG"
  PKG_CONFIG=/usr/bin/false \
  ./configure --disable-dependency-tracking --disable-debug-mode "--prefix=$_PREFIX" \
    --disable-samples --disable-libevent-regress --disable-openssl --disable-shared CFLAGS=-O2

  make -j2 V=1
  make install

  [[ "$_NO_TESTS" != 0 ]] || make check
fi
