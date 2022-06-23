#!/bin/bash
set -xe
_SC_DIR="$(dirname "$0")"

_PREFIX="${1:-/usr/local}"
_SCRATCH_DIR="${2:-$(cd "$_SC_DIR/.."; pwd)}"
_PKG="rustc-${3:-1.59.0}-src"

if [[ ! -x "$_PREFIX/bin/rustc" ]] && command -v python3 &> /dev/null
then
  [[ ":$PATH:" == *:"$_PREFIX/bin":* ]] || export PATH="$_PREFIX/bin:$PATH"
  . "$_SC_DIR/_install_cmake.sh"

  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tar.xz" ]] || curl -OkfSL "https://static.rust-lang.org/dist/$_PKG.tar.xz"
  rm -rf "$_PKG"
  (set +x; while sleep 2; do echo -n .; done) & tar -xf "$_PKG.tar.xz" && kill -9 $!

  cd "$_PKG"
  # Patches
  (
    cd vendor/openssl-src
    _f=openssl/crypto/rand/rand_unix.c; _s="$(shasum -a256 $_f | cut -d' ' -f1)"
    sed -i '' $'s|^\(# *include <CommonCrypto/Common\)Random.h>|\\1CryptoError.h>\\\n&|' $_f
    sed -i '' "s/$_s/$(shasum -a256 $_f | cut -d' ' -f1)/" .cargo-checksum.json
  )

  ./configure "--prefix=$_PREFIX" --release-channel=stable --enable-vendor \
    --disable-docs --python=python3 --disable-manage-submodules --enable-locked-deps \
    --enable-cargo-native-static --set rust.codegen-units-std=1 --enable-parallel-compiler \
    --disable-dist-src --dist-compression-formats=xz --enable-extended --tools=cargo \
    --enable-profiler $(command -v ninja &> /dev/null || echo '--disable-ninja') \
    $(command -v rustc &> /dev/null && echo '--enable-local-rust' || true)
  # --enable-llvm-static-stdcpp --set llvm.download-ci-llvm

  CARGO_HOME="$PWD/.cargo" \
  RUSTFLAGS="$(echo "--remap-path-prefix $PWD"/{vendor,compiler,src,library}/=)" \
  python3 x.py dist -v -j 2 rust-std rustc cargo

  # Install files
  find build/dist -name '*.xz' \
    -exec tar -C "$_PREFIX" --strip-components=2 --exclude=manifest.in -xf "{}" \;
fi
