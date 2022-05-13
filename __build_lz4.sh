#!/bin/bash
set -xe

_PKG=lz4-1.8.3
_PREFIX="$1"
_SCRATCH_DIR="$2"

if [[ ! -e "$_PREFIX/include/lz4.h" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tgz" ]] || \
    curl -o "$_PKG.tgz" -kSL "https://github.com/lz4/lz4/archive/v${_PKG#*-}.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tgz"

  cd "$_PKG/lib"
  make -j2 V=1 install BUILD_SHARED=no "PREFIX=$_PREFIX"

  # Correct the generated .pc file
  sed -i '' -e "s:^libdir=$_PREFIX/:libdir=\${prefix}/:" \
    -e "s:^includedir=$_PREFIX/:includedir=\${prefix}/:" \
    -e 's/^\(Libs: -L\).* -l/\1${libdir} -l/' \
    -e 's/^\(Cflags: -I\).*/\1${includedir}/' "$_PREFIX/lib/pkgconfig/liblz4.pc"
fi
