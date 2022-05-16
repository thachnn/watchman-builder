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
# Add `testing` option
patch -p1 -i "$_SC_DIR/watchman.patch"

[[ "$_NO_TESTS" == 0 ]] && _BUILD_TESTS=ON || _BUILD_TESTS=OFF

cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_FIND_FRAMEWORK=LAST \
  -DCMAKE_VERBOSE_MAKEFILE=ON -Wno-dev "-DBUILD_TESTING=$_BUILD_TESTS" $_EXTRA_ARGS \
  "-DCMAKE_INSTALL_PREFIX=$_PREFIX" "-DCMAKE_PREFIX_PATH=$_PREFIX" \
  "-DWATCHMAN_VERSION_OVERRIDE=${_PKG#*-}" "-DWATCHMAN_BUILDINFO_OVERRIDE=$USER"

make -j2 install
[[ "$_NO_TESTS" != 0 ]] || make test
