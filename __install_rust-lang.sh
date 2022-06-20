#!/bin/bash
set -xe

: "${_PREFIX:=$1}"
: "${_SCRATCH_DIR:=$2}"

if ! command -v cargo &> /dev/null
then
  if [[ ! -x "$_PREFIX/rust/bin/cargo" ]]
  then
  (
    _PKG=rust-1.59.0-x86_64-apple-darwin

    cd "$_SCRATCH_DIR"
    for c in rustc rust-std cargo
    do
      _p="$c-${_PKG#*-}"
      [[ -s "$_p.tar.xz" ]] || curl -ORfSL "https://static.rust-lang.org/dist/$_p.tar.xz"

      # Install manually
      mkdir -p "$_PREFIX/rust"
      tar -C "$_PREFIX/rust" --strip-components=2 --exclude=manifest.in -xf "$_p.tar.xz"
    done
  )
  fi

  export PATH="$_PREFIX/rust/bin:$PATH"
fi
