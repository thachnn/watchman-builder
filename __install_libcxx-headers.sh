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
  [[ -s "$_PKG_.tar.xz" ]] || "$_SC_DIR/download_llvm_pkg.sh" "$_PKG_" "$_VER_"
  tar -C "$_PREFIX" -xf "$_PKG_.tar.xz" --strip-components=1 "$_PKG_/include/variant"

  # Patching...
  sed -i '' -e '/^#include <version>/d;/^#include <__undef_macros>/d' \
    -e '/^_LIBCPP_PUSH_MACROS/d;/^_LIBCPP_POP_MACROS/d' \
    -e 's/\(_LIBCPP_AVAILABILITY_[H-W_]*BAD\)_VARIANT_ACCESS/\1_ANY_CAST/g' \
    -e 's/_LIBCPP_INLINE_VAR /inline /g;s/_LIBCPP_NODEBUG_TYPE //g' \
    -e 's/ _If</ conditional_t</g;s/invoke_result_t</__invoke_of</g' \
    -e 's/is_invocable_v\(<[^>]*>\)/bool_constant<__invokable\1::value>::value/g' \
    -e 's/__enable_hash_helper<\([^,]*\), [^ ,]*\.>/\1/g' \
    -e 's/__is_inplace_index</__is_inplace_type</g' "$_PREFIX/include/variant"

  ${CXX:-clang++} $_TMPCXX_ > /dev/null
)
fi

rm -f "${_TMPCXX_#* -c }"*
unset _TMPCXX_
