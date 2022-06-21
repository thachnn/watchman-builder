#!/bin/bash
set -xe
: "${_SC_DIR:=$(cd "`dirname "$0"`"; pwd)}"

: "${_PREFIX:=$1}"
: "${_SCRATCH_DIR:=$2}"

if ! command -v cargo &> /dev/null
then
  if [[ ! -x "$_PREFIX/rust/bin/cargo" ]]
  then
  (
    _VER=1.59.0
    _PKG="rust-$_VER-x86_64-apple-darwin"

    mkdir -p "$_PREFIX/rust"
    cd "$_SCRATCH_DIR"

    # Install components
    for c in rustc cargo
    do
      _p="$c-${_PKG#*-}"
      [[ -s "$_p.tar.xz" ]] || curl -ORfSL "https://static.rust-lang.org/dist/$_p.tar.xz"

      tar -C "$_PREFIX/rust" --strip-components=2 --exclude=manifest.in -xf "$_p.tar.xz"
    done

    # rust-std component
    "$_PREFIX/rust/bin/cargo" search _
    "$_SC_DIR/build_rust-std.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_VER"
  )
  fi

  export PATH="$_PREFIX/rust/bin:$PATH"
fi
