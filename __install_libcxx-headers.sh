#!/bin/bash
set -xe
: "${_SC_DIR:=$(cd "`dirname "$0"`"; pwd)}"

: "${_PREFIX:=$1}"
: "${_SCRATCH_DIR:=$2}"

# Check missing C++17 headers
_TMPCXX_TEST="$(mktemp -ut cxx17test).cxx"
echo '#include <variant>' > "$_TMPCXX_TEST"

_TMPCXX_TEST="-D_GNU_SOURCE -std=gnu++1z -I$_PREFIX/include -o $_TMPCXX_TEST.o -c $_TMPCXX_TEST"
[[ -z "$SDKROOT" ]] || _TMPCXX_TEST="-isysroot $SDKROOT $_TMPCXX_TEST"
[[ -z "$MACOSX_DEPLOYMENT_TARGET" ]] || \
  _TMPCXX_TEST="-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET $_TMPCXX_TEST"

if ${CXX:-clang++} $_TMPCXX_TEST &> /dev/null
then
  rm -f "${_TMPCXX_TEST#* -c }"*
else
(
  _CLANG_VER='/Library/Developer/CommandLineTools/usr /Applications/Xcode.app/Contents/Developer/Toolchains'
  _CLANG_VER="$(basename "`find $_CLANG_VER -regex '.*/clang/[0-9][^/]*' -print -quit`")"

  _CXX_PKG="libcxx-$_CLANG_VER.src"
  cd "$_SCRATCH_DIR"
  [[ -s "$_CXX_PKG.tar.xz" ]] || \
    curl -OkfSL "https://releases.llvm.org/$_CLANG_VER/$_CXX_PKG.tar.xz"

  tar -C "$_PREFIX" -xf "$_CXX_PKG.tar.xz" --strip-components=1 "$_CXX_PKG/include/variant"

  sed -i '' -e '/^#include <version>/d;/^_LIBCPP_PUSH_MACROS/d;/^_LIBCPP_POP_MACROS/d' \
    "$_PREFIX/include/variant"
  cd "$_PREFIX/include" && patch -p1 -i "$_SC_DIR/libcxx-headers.patch"

  ${CXX:-clang++} $_TMPCXX_TEST || rm -f "${_TMPCXX_TEST#* -c }"* && exit 1
)
fi

unset _TMPCXX_TEST
