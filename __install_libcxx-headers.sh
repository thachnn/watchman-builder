#!/bin/bash
set -xe
: "${_SC_DIR:=$(cd "`dirname "$0"`"; pwd)}"

: "${_PREFIX:=$1}"
: "${_SCRATCH_DIR:=$2}"

# Check missing C++17 headers
_TMPCXX="$(mktemp -ut cxx17test).cxx"
echo '#include <variant>' > "$_TMPCXX"

_TMPCXX="-D_GNU_SOURCE -std=gnu++1z -I$_PREFIX/include -o $_TMPCXX.o -c $_TMPCXX"
[[ -z "$SDKROOT" ]] || _TMPCXX="-isysroot $SDKROOT $_TMPCXX"
[[ -z "$MACOSX_DEPLOYMENT_TARGET" ]] || \
  _TMPCXX="-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET $_TMPCXX"

if ${CXX:-clang++} $_TMPCXX &> /dev/null
then
  rm -f "${_TMPCXX#* -c }"*
else
(
  _PKG_VER="$( $_SC_DIR/get_clang_ver.sh || echo 9.0.0 )"
  _CXX_PKG="libcxx-$_PKG_VER.src"

  cd "$_SCRATCH_DIR"
  [[ -s "$_CXX_PKG.tar.xz" ]] || \
    curl -OkSL "https://releases.llvm.org/$_PKG_VER/$_CXX_PKG.tar.xz"

  cd "$_PREFIX/include"
  tar -xf "$_CXX_PKG.tar.xz" --strip-components=2 "$_CXX_PKG/include/variant"

  patch -p1 -i "$_SC_DIR/libcxx-headers.patch"
  sed -i '' -e '/^_LIBCPP_PUSH_MACROS/d;/^_LIBCPP_POP_MACROS/d' \
    -e '/^#include <version>/d' variant

  ${CXX:-clang++} $_TMPCXX || rm -f "${_TMPCXX#* -c }"* && exit 1
)
fi

unset _TMPCXX
