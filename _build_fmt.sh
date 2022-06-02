#!/bin/bash
set -xe

_PKG=fmt-6.1.2
_PREFIX="$1"
_SCRATCH_DIR="$2"
_NO_TESTS="$3"

if [[ ! -e "$_PREFIX/lib/cmake/fmt" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tgz" ]] || \
    curl -o "$_PKG.tgz" -kfSL "https://github.com/fmtlib/fmt/archive/${_PKG#*-}.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tgz"

  cd "$_PKG"
  sed -i- 's/^\(exec_prefix=\).*/\1${prefix}/' support/cmake/fmt.pc.in

  cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_FIND_FRAMEWORK=LAST \
    -DCMAKE_VERBOSE_MAKEFILE=ON -Wno-dev "-DCMAKE_INSTALL_PREFIX=$_PREFIX" -DFMT_DOC=OFF \
    -DBUILD_SHARED_LIBS=OFF -DFMT_TEST=$([[ "$_NO_TESTS" == 0 ]] && echo ON || echo OFF)

  make -j2 install
  [[ "$_NO_TESTS" != 0 ]] || make test
fi
