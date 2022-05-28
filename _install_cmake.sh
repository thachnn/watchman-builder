#!/bin/bash
set -xe

: "${_PREFIX:=$1}"
: "${_SCRATCH_DIR:=$2}"

if ! command -v cmake &> /dev/null
then
  if [[ ! -x "$_PREFIX/bin/cmake" ]]
  then
  (
    _PKG=cmake-3.18.6-Darwin-x86_64

    cd "$_SCRATCH_DIR"
    while ! shasum -cs <<< "676dc3f1d6f15cd7c1d9f4fa7e2a43613f426cd20783c02d4fdb5e139f39eec3 *$_PKG.tar.gz"
    do
      curl -OkfSL "https://github.com/Kitware/CMake/releases/download/v${_PKG:6:6}/$_PKG.tar.gz"
    done
    rm -rf "$_PKG"
    tar -xf "$_PKG.tar.gz"

    # Install files
    cp -af "$_PKG/CMake.app/Contents/bin" "$_PREFIX/"
    cp -af "$_PKG/CMake.app/Contents/share" "$_PREFIX/"
    rm -rf "$_PKG"
  )
  fi

  export PATH="$_PREFIX/bin:$PATH"
fi
