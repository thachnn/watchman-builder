#!/bin/bash
set -xe
_SC_DIR="$(cd "`dirname "$0"`"; pwd)"

_PKG=watchman-2021.02.15.00
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
patch -p1 -i "$_SC_DIR/watchman.patch"

CMAKE_PREFIX_PATH="$_PREFIX" \
cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_FIND_FRAMEWORK=LAST \
  -DCMAKE_VERBOSE_MAKEFILE=ON -Wno-dev \
  -DWATCHMAN_VERSION_OVERRIDE=2021.02.15 -DWATCHMAN_BUILDINFO_OVERRIDE=github.com/thachnn \
  "-DCMAKE_INSTALL_PREFIX=$_PREFIX" $_EXTRA_ARGS

make -j2
[[ "$_NO_TESTS" == 1 ]] || make check
make install
