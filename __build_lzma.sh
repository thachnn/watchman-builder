#!/bin/bash
set -xe

_PKG=xz-5.2.5
_PREFIX="$1"
_SCRATCH_DIR="$2"

if [[ ! -e "$_PREFIX/include/lzma.h" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tar.bz2" ]] || \
    curl -OkSL "https://downloads.sourceforge.net/project/lzmautils/$_PKG.tar.bz2"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tar.bz2"

  cd "$_PKG"
  ./configure --disable-dependency-tracking --disable-debug "--prefix=$_PREFIX" \
    --disable-shared --disable-doc --disable-xz --disable-xzdec --disable-scripts \
    --disable-lzmadec --disable-lzmainfo --disable-lzma-links CFLAGS=-O2

  make -j2 V=1
  make install

  # Correct the generated .pc file
  sed -i '' -e "s:^libdir=$_PREFIX/:libdir=\${exec_prefix}/:" \
    -e "s:^includedir=$_PREFIX/:includedir=\${prefix}/:" \
    -e 's/^\(exec_prefix=\).*/\1${prefix}/' "$_PREFIX/lib/pkgconfig/liblzma.pc"
fi
