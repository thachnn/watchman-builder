#!/bin/sh
_PKG="$1"
_VER="${2:-$(sed -e 's/^.*-//;s/\.src$//' <<< "$_PKG")}"

curl -OkfSL "https://github.com/llvm/llvm-project/releases/download/llvmorg-$_VER/$_PKG.tar.xz" \
  || curl -OkfSL "https://releases.llvm.org/$_VER/$_PKG.tar.xz"
