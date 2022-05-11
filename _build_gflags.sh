#!/bin/bash
set -xe

_PKG=gflags-2.2.2
_PREFIX="$1"
_SCRATCH_DIR="$2"

if [[ ! -e "$_PREFIX/lib/cmake/gflags" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tgz" ]] || \
    curl -o "$_PKG.tgz" -kSL "https://github.com/gflags/gflags/archive/v${_PKG#*-}.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tgz"

  cd "$_PKG"
  cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_FIND_FRAMEWORK=LAST \
    -DCMAKE_VERBOSE_MAKEFILE=ON -Wno-dev -DBUILD_TESTING=OFF \
    "-DCMAKE_INSTALL_PREFIX=$_PREFIX" -DREGISTER_INSTALL_PREFIX=OFF

  # Use relative paths
  find CMakeFiles -name build.make -exec sed -i- "s:-c $PWD/:-c :" {} +
  make -j2 install
fi
