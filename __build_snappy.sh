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
  # Fix compilation for Clang version that doesn't supports ASM flag outputs
  curl -kfSL 'https://github.com/google/snappy/commit/8dd58a519f79f0742d4c68fbccb2aed2ddb651e8.patch' | patch -p1
  # Patch tests
  sed -i- -e 's/(GTest QUIET)/(GTest)/;s/(Gflags QUIET)/(gflags)/' \
    -e 's/GFLAGS_FOUND/gflags_FOUND/;s/\(GFLAGS_INCLUDE_DIR\)S/\1/' \
    -e 's/\${GFLAGS_LIBRARIES}/${GTEST_LIBRARIES} &/' CMakeLists.txt

  cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_FIND_FRAMEWORK=LAST \
    -DCMAKE_VERBOSE_MAKEFILE=ON -Wno-dev "-DCMAKE_INSTALL_PREFIX=$_PREFIX" \
    "-DCMAKE_PREFIX_PATH=$_PREFIX" -DBUILD_SHARED_LIBS=OFF -DSNAPPY_BUILD_BENCHMARKS=OFF \
    '-DCMAKE_CXX_FLAGS=-Wall -Wextra -Werror -Wno-missing-braces' \
    -DSNAPPY_BUILD_TESTS=$([[ "$_NO_TESTS" == 0 ]] && echo ON || echo OFF)

  make -j2 install
  [[ "$_NO_TESTS" != 0 ]] || make test
fi
