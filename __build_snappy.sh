#!/bin/bash
set -xe

_PKG=snappy-1.1.8
_PREFIX="$1"
_SCRATCH_DIR="$2"
_NO_TESTS="$3"

# Testing depends on: lzo2
if [[ ! -e "$_PREFIX/lib/cmake/Snappy" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tgz" ]] || \
    curl -o "$_PKG.tgz" -kfSL "https://github.com/google/snappy/archive/${_PKG#*-}.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tgz"

  cd "$_PKG"
  cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_FIND_FRAMEWORK=LAST \
    -DCMAKE_VERBOSE_MAKEFILE=ON -Wno-dev "-DCMAKE_INSTALL_PREFIX=$_PREFIX" \
    "-DCMAKE_PREFIX_PATH=$_PREFIX" -DBUILD_SHARED_LIBS=OFF \
    -DSNAPPY_BUILD_TESTS=$([[ "$_NO_TESTS" == 0 ]] && echo ON || echo OFF)

  make -j2 install
  [[ "$_NO_TESTS" != 0 ]] || make test
fi
