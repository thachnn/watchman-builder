#!/bin/bash
set -xe

_PKG=snappy-1.1.9
_PREFIX="$1"
_SCRATCH_DIR="$2"

# Testing depends on: lzo2, lz4
if [[ ! -e "$_PREFIX/lib/cmake/Snappy" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tgz" ]] || \
    curl -o "$_PKG.tgz" -kfSL "https://github.com/google/snappy/archive/${_PKG#*-}.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tgz"

  cd "$_PKG"
  # Fix error "invalid '=@ccz' in asm" for older Clang
  curl -kfSL 'https://github.com/google/snappy/commit/8dd58a519f79f0742d4c68fbccb2aed2ddb651e8.patch' | patch -p1

  cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_FIND_FRAMEWORK=LAST \
    -DCMAKE_VERBOSE_MAKEFILE=ON -Wno-dev "-DCMAKE_INSTALL_PREFIX=$_PREFIX" \
    -DSNAPPY_BUILD_TESTS=OFF -DBUILD_SHARED_LIBS=OFF -DSNAPPY_BUILD_BENCHMARKS=OFF \
    '-DCMAKE_CXX_FLAGS=-Wall -Wextra -Werror -Wno-missing-braces'

  make -j2 install
fi
