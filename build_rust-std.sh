#!/bin/bash
set -xe
_SC_DIR="$(dirname "$0")"

_PREFIX="${1:-/usr/local}"
_SCRATCH_DIR="${2:-$(cd "$_SC_DIR/.."; pwd)}"
_PKG="rust-${3:-1.59.0}"
_TRIPLE=x86_64-apple-darwin

if [[ ! -e "$_PREFIX/rust/lib/rustlib/$_TRIPLE/lib" ]]
then
  . "$_SC_DIR/_install_cmake.sh"

  cd "$_SCRATCH_DIR"
  rm -rf "$_PKG"
  git clone --depth=1 -b "${_PKG#*-}" https://github.com/rust-lang/rust.git "$_PKG"

  cd "$_PKG"
  git rm -r $(grep -e $'^[ \t]*path *= *src/doc/' .gitmodules | sed 's/^.*path *= *//')
  git submodule update --init --depth=1 # --recursive

  # ./configure --release-channel=stable
  sed -e 's|^[# ]*\(configure-args\) *=.*|\1 = ["--release-channel=stable"]|' \
    -e 's/^[# ]*channel *=.*/channel = "stable"/;s/^[# ]*ninja *=.*/ninja = false/' \
    -e "s/^ *\[target\..*-unknown-.*\]/[target.$_TRIPLE]/" config.toml.example > config.toml

  # Hash of crates.io source
  _dir="$((ls -1t "$HOME/.cargo/registry/index" || echo github.com-1ecc6299db9ec823) | head -1)"
  RUSTFLAGS="--remap-path-prefix $HOME/.cargo/registry/src/$_dir/= --remap-path-prefix $PWD/=" \
  ./x.py build --stage 0 library/std

  # Install files
  mkdir -p "$_PREFIX/rust/lib/rustlib"
  cp -af "build/$_TRIPLE/stage0-sysroot/lib/rustlib/$_TRIPLE" "$_PREFIX/rust/lib/rustlib"
  ln -sf ../../../librustc-stable_rt.{a,l,t}san.dylib "$_PREFIX/rust/lib/rustlib/$_TRIPLE/lib"
fi
