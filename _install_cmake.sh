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

    # Install files
    mkdir -p "$_PREFIX"
    tar -C "$_PREFIX" -xf "$_PKG.tar.gz" --strip-components=3 "$_PKG/CMake.app/Contents"/{bin,share} || true
    rm -f "$_PREFIX/bin/cmake-gui"
  )
  fi

  export PATH="$_PREFIX/bin:$PATH"
fi
