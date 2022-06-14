#!/bin/bash
set -xe

_PKG=zstd-1.4.9
_PREFIX="$1"
_SCRATCH_DIR="$2"
_NO_TESTS="$3"

if [[ ! -e "$_PREFIX/include/zstd.h" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tar.gz" ]] || \
    curl -OkfSL "https://github.com/facebook/zstd/releases/download/v${_PKG#*-}/$_PKG.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tar.gz"

  cd "$_PKG/lib"
  sed -i- 's/install-static:$/& libzstd.a/' Makefile
  make -j2 V=1 install-static-mt install-includes install-pc "PREFIX=$_PREFIX" BUILD_DIR=obj

  # Correct .pc file
  sed -i '' -e "s:=$_PREFIX:=\${prefix}:;s:^prefix=\\\$.*:prefix=$_PREFIX:" \
    -e 's/^libdir=\${prefix}/libdir=${exec_prefix}/' "$_PREFIX/lib/pkgconfig/libzstd.pc"

  if [[ "$_NO_TESTS" == 0 ]]; then
    cd ../tests
    for i in common=m compress=c decompress=d legacy=l; do
      for j in "../lib/${i%=*}"/*.c; do
        f="$(basename "${j%.c}.o")"
        [[ ! -e "../lib/obj/static/$f" ]] || \
          for k in mt_ ''; do ln -s "../lib/obj/static/$f" "./zstd$k${i#*=}_$f"; done
      done
    done

    make -j2 test-fuzzer test-zstream test-invalidDictionaries test-decodecorpus DEBUGLEVEL=0 \
      "MOREFLAGS=-DXXH_NAMESPACE=ZSTD_ -DZSTD_LEGACY_SUPPORT=4 $(echo zstdmt_l_*.o)"
    make -j2 test-legacy DEBUGLEVEL=0 MOREFLAGS=-DXXH_NAMESPACE=ZSTD_
  fi
fi
