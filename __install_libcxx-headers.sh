#!/bin/bash
set -xe

: "${_PREFIX:=$1}"
: "${_SCRATCH_DIR:=$2}"

# Check missing C++17 headers
_TMPCXX_="$(mktemp -ut cxx17test).cxx"
echo '#include <variant>
#include <optional>

int main() {
  std::variant<float, int> v(0);
  std::optional<int> o(0);

  long n;
  unsigned long *addr;
  int b;
  asm volatile("bt %2,%1" : "=@ccc" (b) : "m" (*addr), "Ir" (n));
  return b;
}' > "$_TMPCXX_"

_TMPCXX_="-D_GNU_SOURCE -std=gnu++1z -I$_PREFIX/include -o $_TMPCXX_.o -c $_TMPCXX_"
[[ -z "$SDKROOT" ]] || _TMPCXX_="-isysroot $SDKROOT $_TMPCXX_"
[[ -z "$MACOSX_DEPLOYMENT_TARGET" ]] || \
  _TMPCXX_="-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET $_TMPCXX_"

if ! ${CXX:-clang++} $_TMPCXX_ &> /dev/null
then
  if [[ ! -x "$_PREFIX/llvm/bin/clang" ]]
  then
  (
    _SC_DIR="$(cd "`dirname "$0"`"; pwd)"
    _VER="$( "$_SC_DIR/get_clang_ver.sh" || echo '9.0.0' )"
    _PKG="clang+llvm-$_VER-x86_64"

    cd "$_SCRATCH_DIR"
    [ -s "$_PKG"-*.tar.xz ] || \
      "$_SC_DIR/download_llvm_pkg.sh" "$_PKG-apple-darwin" "$_VER" || \
      "$_SC_DIR/download_llvm_pkg.sh" "$_PKG-darwin-apple" "$_VER"

    (set +x; while sleep 2; do echo -n .; done) & \
      tar -C "$_PREFIX" -xf "$_PKG"-*.tar.xz && kill -9 $!
    mv -f "$_PREFIX/$_PKG"-* "$_PREFIX/llvm"

    sed -i- 's/(\(macosx,strict,introduced\)=1[0-3][0-9.]*)/(\1=10.9)/' \
      "$_PREFIX/llvm/include/c++/v1/__config"
  )
  fi

  export PATH="$_PREFIX/llvm/bin:$PATH"
  ${CXX:-clang++} $_TMPCXX_ > /dev/null
fi

rm -f "${_TMPCXX_#* -c }"*
unset _TMPCXX_
