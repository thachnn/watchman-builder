#!/bin/bash
set -xe

_PKG=snappy-1.1.9
_PREFIX="$1"
_SCRATCH_DIR="$2"
_NO_TESTS="$3"

# Testing depends on: lzo2, lz4
if [[ ! -e "$_PREFIX/lib/cmake/Snappy" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tgz" ]] || \
    curl -o "$_PKG.tgz" -kfSL "https://github.com/google/snappy/archive/${_PKG#*-}.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tgz"

  cd "$_PKG"
  # Patch tests
  sed -i- -e 's|"" HAVE_LIBLZ|"${CMAKE_PREFIX_PATH}/lib" HAVE_LIBLZ|' \
    -e 's|^ *"\${PROJECT_SOURCE_DIR}"|& "${CMAKE_PREFIX_PATH}/include"|' \
    -e 's|^\( *target_link_\)libraries *(\(snappy_test_support\) snappy)|&\
\1directories(\2 PUBLIC "${CMAKE_PREFIX_PATH}/lib")|;s/ gmock_main gtest/ gmock&/' \
    -e 's|^ *add_subdirectory.*third_party/googletest|# &|' \
    -e 's/(SNAPPY_HAVE_NO_MISSING_FIELD_INITIALIZERS)/(FALSE)/' CMakeLists.txt

  cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_FIND_FRAMEWORK=LAST \
    -DCMAKE_VERBOSE_MAKEFILE=ON -Wno-dev "-DCMAKE_INSTALL_PREFIX=$_PREFIX" \
    "-DCMAKE_PREFIX_PATH=$_PREFIX" -DBUILD_SHARED_LIBS=OFF -DSNAPPY_BUILD_BENCHMARKS=OFF \
    -DSNAPPY_BUILD_TESTS=$([[ "$_NO_TESTS" == 0 ]] && echo ON || echo OFF)
  # '-DCMAKE_CXX_FLAGS=-Wall -Wextra -Werror -Wno-missing-braces'

  make -j2 install
  [[ "$_NO_TESTS" != 0 ]] || make test
fi
