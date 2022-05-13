#!/bin/bash
set -xe

_PKG=zstd-1.4.5
_PREFIX="$1"
_SCRATCH_DIR="$2"

if [[ ! -e "$_PREFIX/include/zstd.h" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tar.gz" ]] || \
    curl -OkSL "https://github.com/facebook/zstd/releases/download/v${_PKG#*-}/$_PKG.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tar.gz"

  cd "$_PKG/lib"
  make -j2 V=1 install-static install-includes install-pc "PREFIX=$_PREFIX"
fi
