#!/bin/bash
set -xe
_SC_DIR="$(cd "`dirname "$0"`"; pwd)"

_PKG=libunwind-9.0.0.src
_PREFIX="$1"
_SCRATCH_DIR="$2"

if [[ ! -e "$_PREFIX/lib/libunwind.a" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tar.xz" ]] || \
    curl -OkSL "https://releases.llvm.org/${_PKG:10:5}/$_PKG.tar.xz"

  # Install headers
  tar -C "$_PREFIX" -xf "$_PKG.tar.xz" --strip-components=1 "$_PKG/include"

  # Install static library
  cd "$_PREFIX/lib"
  git apply "$_SC_DIR/libunwind.patch"

  echo '2b89581fe31d091a1bbe015beda13565598f148785c85c0cf9e317a3a68f5b48 *libunwind.a' \
    | shasum -c
fi
