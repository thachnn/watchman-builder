#!/bin/bash
set -xe

: "${_PREFIX:=$1}"
: "${_SCRATCH_DIR:=$2}"

if ! command -v cmake &> /dev/null
then
  if [[ ! -x "$_PREFIX/bin/cmake" ]]
  then
  (
    _PKG=cmake-3.21.6-macos10.10-universal

    cd "$_SCRATCH_DIR"
    while ! shasum -cs <<< "6451134d0ded2a5c7bf403d90888b3254c6e9a9db72b8f393eca2012d7da6a1a *$_PKG.tar.gz"
    do
      curl -OkfSL "https://github.com/Kitware/CMake/releases/download/v${_PKG:6:6}/$_PKG.tar.gz"
    done
    rm -rf "$_PKG"
    tar -xf "$_PKG.tar.gz"

    # Install files
    mkdir -p "$_PREFIX"
    cp -af "$_PKG/CMake.app/Contents/bin" "$_PREFIX/"
    cp -af "$_PKG/CMake.app/Contents/share" "$_PREFIX/"
    rm -rf "$_PKG"
  )
  fi

  export PATH="$_PREFIX/bin:$PATH"
fi
