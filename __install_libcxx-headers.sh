#!/bin/bash
set -xe
: "${_SC_DIR:=$(cd "`dirname "$0"`"; pwd)}"

: "${_PREFIX:=$1}"
: "${_SCRATCH_DIR:=$2}"

# Check missing C++17 headers
_TMPCXX_="$(mktemp -ut cxx17test).cxx"
echo '#include <variant>' > "$_TMPCXX_"

_TMPCXX_="-D_GNU_SOURCE -std=gnu++1z -I$_PREFIX/include -o $_TMPCXX_.o -c $_TMPCXX_"
[[ -z "$SDKROOT" ]] || _TMPCXX_="-isysroot $SDKROOT $_TMPCXX_"
[[ -z "$MACOSX_DEPLOYMENT_TARGET" ]] || \
  _TMPCXX_="-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET $_TMPCXX_"

if ! ${CXX:-clang++} $_TMPCXX_ &> /dev/null
then
(
  _VER_="$( "$_SC_DIR/get_clang_ver.sh" || echo 9.0.0 )"
  _PKG_="libcxx-$_VER_.src"

  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG_.tar.xz" ]] || curl -OkSL "https://releases.llvm.org/$_VER_/$_PKG_.tar.xz"
  tar -C "$_PREFIX" -xf "$_PKG_.tar.xz" --strip-components=1 "$_PKG_/include/variant"

  cd "$_PREFIX/include"
  patch -p1 -i "$_SC_DIR/libcxx-headers.patch"

  sed -i '' -e '/^_LIBCPP_PUSH_MACROS/d;/^_LIBCPP_POP_MACROS/d' \
    -e '/^#include <version>/d' variant

  ${CXX:-clang++} $_TMPCXX_ > /dev/null
)
fi

rm -f "${_TMPCXX_#* -c }"*
unset _TMPCXX_
