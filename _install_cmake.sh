#!/bin/bash
set -xe

: "${_PREFIX:=$1}"
: "${_SCRATCH_DIR:=$2}"

if ! command -v cmake &> /dev/null
then
  if [[ ! -x "$_PREFIX/bin/cmake" ]]
  then
    _PKG=cmake-3.18.6-Darwin-x86_64

    cd "$_SCRATCH_DIR"
    [[ -s "$_PKG.tar.gz" ]] || \
      curl -OkSL "https://github.com/Kitware/CMake/releases/download/v${_PKG:6:6}/$_PKG.tar.gz"
    rm -rf "$_PKG"
    tar -xf "$_PKG.tar.gz"

    # Install files
    cp -af "$_PKG/CMake.app/Contents/bin" "$_PREFIX/"
    cp -af "$_PKG/CMake.app/Contents/share" "$_PREFIX/"
    rm -rf "$_PKG"

    unset _PKG
  fi

  export PATH="$_PREFIX/bin:$PATH"
fi
