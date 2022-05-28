#!/bin/bash
set -xe

_PKG=libsodium-1.0.17-stable
_DIR="${_PKG%%-*}-${_PKG##*-}"
_PREFIX="$1"
_SCRATCH_DIR="$2"

if [[ ! -e "$_PREFIX/lib/libsodium.a" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tar.gz" ]] || \
    curl -OkfSL "https://download.libsodium.org/libsodium/releases/$_PKG.tar.gz"
  rm -rf "$_DIR"
  tar -xf "$_PKG.tar.gz"

  cd "$_DIR"
  ./configure --disable-dependency-tracking --disable-debug \
    "--prefix=$_PREFIX" --disable-shared CFLAGS=-O2

  make -j2 V=1
  make install
fi
