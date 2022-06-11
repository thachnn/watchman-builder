#!/bin/bash
set -xe

: "${_PREFIX:=$1}"

# Check missing C++17 headers
_TMPCXX_="$(mktemp -ut cxx17test).cxx"
echo '#include <variant>
int main() { std::variant<float, int> v(0); return 0; }' > "$_TMPCXX_"

_TMPCXX_="-D_GNU_SOURCE -std=gnu++1z -I$_PREFIX/include -o $_TMPCXX_.o -c $_TMPCXX_"
[[ -z "$SDKROOT" ]] || _TMPCXX_="-isysroot $SDKROOT $_TMPCXX_"
[[ -z "$MACOSX_DEPLOYMENT_TARGET" ]] || \
  _TMPCXX_="-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET $_TMPCXX_"

if ! ${CXX:-clang++} $_TMPCXX_ &> /dev/null
then
  mkdir -p "$_PREFIX/include"
  # C++17 std::variant patching...
  curl -kfSL https://github.com/apple/swift-libcxx/raw/swift-5.0-RELEASE/include/variant \
    | sed -e 's/^\(#include <__undef\)_macros>/\1_min_max>/' \
      -e '/^_LIBCPP_P[H-U]*_MACROS$/d;s/_LIBCPP_INLINE_VAR /inline /' \
      -e 's/is_invocable_v<\([^ ,]*\), \([^>]*\)>/is_callable_v<\1(\2)>/' \
      -e 's/__enable_hash_helper<\([^ ,]*\), .*>> /\1> /' \
      -e '/^ *enable_if_t<!__is_inplace_index<.*> = 0,$/d' \
    > "$_PREFIX/include/variant"

  ${CXX:-clang++} $_TMPCXX_ > /dev/null
fi

# C++17 std::optional patching...
echo '#include <optional>
int main() { std::optional<int> v(0); return 0; }' > "${_TMPCXX_#* -c }"

if ! ${CXX:-clang++} $_TMPCXX_ &> /dev/null
then
  mkdir -p "$_PREFIX/include"
  echo '#pragma once
#include <experimental/optional>
namespace std { using namespace experimental; }' > "$_PREFIX/include/optional"

  ${CXX:-clang++} $_TMPCXX_ > /dev/null
fi

rm -f "${_TMPCXX_#* -c }"*
unset _TMPCXX_
