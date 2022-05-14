#!/bin/bash
set -xe

_PKG=double-conversion-3.1.5
_PREFIX="$1"
_SCRATCH_DIR="$2"

if [[ ! -e "$_PREFIX/lib/cmake/double-conversion" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tgz" ]] || \
    curl -o "$_PKG.tgz" -kSL "https://github.com/google/double-conversion/archive/v${_PKG##*-}.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tgz"

  cd "$_PKG"
  cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_FIND_FRAMEWORK=LAST \
    -DCMAKE_VERBOSE_MAKEFILE=ON -Wno-dev -DBUILD_TESTING=OFF \
    -DBUILD_SHARED_LIBS=OFF "-DCMAKE_INSTALL_PREFIX=$_PREFIX"

  make -j2 install
fi
