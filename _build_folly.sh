#!/bin/bash
set -xe
_SC_DIR="$(cd "`dirname "$0"`"; pwd)"

_PKG=folly-2022.05.16.00
_PREFIX="$1"
_SCRATCH_DIR="$2"
_NO_TESTS="$3"

# Depends on: Boost DoubleConversion Gflags Glog LibEvent OpenSSL LZMA LZ4 Zstd Snappy
#            (LibDwarf LibIberty LibAIO LibUring)? Libsodium LibUnwind fmt, GoogleTest
if [[ ! -e "$_PREFIX/lib/cmake/folly" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tgz" ]] || \
    curl -o "$_PKG.tgz" -kfSL "https://github.com/facebook/folly/archive/v${_PKG#*-}.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tgz"

  cd "$_PKG"
  # Fix package finding issues
  patch -p1 -i "$_SC_DIR/folly.patch"

  sed -i- 's/:\${CMAKE_BINARY_DIR}//' CMakeLists.txt
  [[ "$_NO_TESTS" == 0 ]] && _BUILD_TESTS=ON || _BUILD_TESTS=OFF

  cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_FIND_FRAMEWORK=LAST \
    -DCMAKE_VERBOSE_MAKEFILE=ON -Wno-dev "-DBUILD_TESTS=$_BUILD_TESTS" \
    "-DCMAKE_INSTALL_PREFIX=$_PREFIX" "-DCMAKE_PREFIX_PATH=$_PREFIX" \
    -DBOOST_LINK_STATIC=ON -DFOLLY_CXX_FLAGS=-Wno-unusable-partial-specialization
  # -DBUILD_SHARED_LIBS=OFF -DFOLLY_USE_JEMALLOC=OFF

  # Use relative paths
  find CMakeFiles -name build.make -exec sed -i- "s:-c $PWD/:-c :" {} +
  find CMakeFiles -name flags.make -exec sed -i- "s:-I$PWD:-I.:g" {} +
  find */CMakeFiles -name build.make -exec sed -i- "s:-c $PWD/[^ /]*/:-c :" {} +

  make -j2 install
  [[ "$_NO_TESTS" != 0 ]] || make test
fi
