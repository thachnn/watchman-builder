#!/bin/bash
set -xe

_PKG=fmt-7.1.3
_PREFIX="$1"
_SCRATCH_DIR="$2"

if [[ ! -e "$_PREFIX/lib/cmake/fmt" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tgz" ]] || \
    curl -o "$_PKG.tgz" -kSL "https://github.com/fmtlib/fmt/archive/${_PKG#*-}.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tgz"

  cd "$_PKG"
  sed -i- 's/^\(exec_prefix=\).*/\1${prefix}/' support/cmake/fmt.pc.in

  cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_FIND_FRAMEWORK=LAST \
    -DCMAKE_VERBOSE_MAKEFILE=ON -Wno-dev -DFMT_TEST=OFF -DFMT_DOC=OFF \
    -DBUILD_SHARED_LIBS=OFF "-DCMAKE_INSTALL_PREFIX=$_PREFIX"

  make -j2 install
fi
