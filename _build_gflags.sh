#!/bin/bash
set -xe

_PKG=gflags-2.2.2
_PREFIX="$1"
_SCRATCH_DIR="$2"
_NO_TESTS="$3"

if [[ ! -e "$_PREFIX/lib/cmake/gflags" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tgz" ]] || \
    curl -o "$_PKG.tgz" -kfSL "https://github.com/gflags/gflags/archive/v${_PKG#*-}.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tgz"

  cd "$_PKG"
  cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_FIND_FRAMEWORK=LAST \
    -DCMAKE_VERBOSE_MAKEFILE=ON -Wno-dev "-DCMAKE_INSTALL_PREFIX=$_PREFIX" \
    -DREGISTER_INSTALL_PREFIX=OFF -DBUILD_TESTING=$([[ "$_NO_TESTS" == 0 ]] && echo ON || echo OFF)

  # Use relative paths
  find CMakeFiles -name build.make -exec sed -i- "s:-c $PWD/:-c :" {} +

  make -j2 install
  [[ "$_NO_TESTS" != 0 ]] || make test
fi
