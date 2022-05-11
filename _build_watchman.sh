#!/bin/bash
set -xe
_SC_DIR="$(cd "`dirname "$0"`"; pwd)"

_PKG=watchman-4.9.0
_PREFIX="$1"
_SCRATCH_DIR="$2"
_EXTRA_ARGS="$3"
_NO_TESTS="$4"

cd "$_SCRATCH_DIR"
[[ -s "$_PKG.tgz" ]] || \
  curl -o "$_PKG.tgz" -kSL "https://github.com/facebook/watchman/archive/v${_PKG#*-}.tar.gz"
rm -rf "$_PKG"
tar -xf "$_PKG.tgz"

cd "$_PKG"
unzip -q "$_SC_DIR/watchman.patch.zip"
./configure "--prefix=$_PREFIX" CXXFLAGS=-O2 CFLAGS=-O2 $_EXTRA_ARGS

[[ "$_NO_TESTS" == 0 ]] || sed -i- 's/^\(noinst_PROGRAMS *=\).*/\1/' Makefile
make -j2 V=1
[[ "$_NO_TESTS" != 0 ]] || make check
make install
