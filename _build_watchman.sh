#!/bin/bash
set -xe
_SC_DIR="$(cd "`dirname "$0"`"; pwd)"

_PKG=watchman-2022.05.16.00
_PREFIX="$1"
_SCRATCH_DIR="$2"
_EXTRA_ARGS="$3"
_NO_TESTS="$4"

cd "$_SCRATCH_DIR"
[[ -s "$_PKG.tgz" ]] || \
  curl -o "$_PKG.tgz" -kfSL "https://github.com/facebook/watchman/archive/v${_PKG#*-}.tar.gz"
rm -rf "$_PKG"
tar -xf "$_PKG.tgz"

cd "$_PKG"
# Add `testing` option
patch -p1 -i "$_SC_DIR/watchman.patch"

_cxxlib="$(which ${CXX:-clang++} | sed 's|^\(.*\)/.*/.*|\1/lib|')"
[[ ! -e "$_cxxlib/libc++.dylib" || "$_NO_TESTS" != 0 ]] || \
  sed -i- "s|\(_libraries *(testsupport .*\))\$|\\1 -L$_cxxlib -Wl,-rpath,$_cxxlib)|" CMakeLists.txt

cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_FIND_FRAMEWORK=LAST \
  -DCMAKE_VERBOSE_MAKEFILE=ON -Wno-dev "-DCMAKE_INSTALL_PREFIX=$_PREFIX" \
  "-DCMAKE_PREFIX_PATH=$_PREFIX" -DBUILD_TESTING=OFF $_EXTRA_ARGS \
  -DCMAKE_CXX_FLAGS=-fno-aligned-allocation -DCMAKE_BUILD_WITH_INSTALL_RPATH=OFF \
  "-DWATCHMAN_VERSION_OVERRIDE=${_PKG#*-}" "-DWATCHMAN_BUILDINFO_OVERRIDE=$USER"

# Use relative paths
find CMakeFiles -name flags.make -exec sed -i- "s:-I$PWD:-I.:g" {} + \
  -o -name build.make -exec sed -i- "s:-c $PWD/:-c :" {} +

make -j2 install
[[ "$_NO_TESTS" != 0 ]] || make check
