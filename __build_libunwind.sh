#!/bin/bash
set -xe
_SC_DIR="$(cd "`dirname "$0"`"; pwd)"

_PKG=libunwind-9.0.0.src
_PREFIX="$1"
_SCRATCH_DIR="$2"

if [[ ! -e "$_PREFIX/lib/libunwind.a" ]]
then
  _VER="$( "$_SC_DIR/get_clang_ver.sh" || echo "${_PKG:10:5}" )"
  _PKG="${_PKG%-*}-$_VER.${_PKG##*.}"
  _DEP="llvm-${_PKG#*-}"

  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tar.xz" ]] || "$_SC_DIR/download_llvm_pkg.sh" "$_PKG" "$_VER"
  [[ -s "$_DEP.tar.xz" ]] || "$_SC_DIR/download_llvm_pkg.sh" "$_DEP" "$_VER"

  rm -rf "$_PKG"
  tar -xf "$_PKG.tar.xz"
  tar -C "$_PKG" -xf "$_DEP.tar.xz" --strip-components=1 "$_DEP/cmake/modules"

  cd "$_PKG"
  sed -i- 's/^if (EXISTS \${LLVM_CMAKE_PATH}/& AND LLVM_INCLUDE_TESTS/' CMakeLists.txt

  cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_FIND_FRAMEWORK=LAST \
    -DCMAKE_VERBOSE_MAKEFILE=ON -Wno-dev "-DCMAKE_INSTALL_PREFIX=$_PREFIX" \
    "-DLLVM_PATH=$PWD" -DLLVM_INCLUDE_TESTS=OFF -DLIBUNWIND_ENABLE_SHARED=OFF

  # Use relative paths
  find */CMakeFiles -name build.make -exec sed -i- "s:-c $PWD/[^ /]*/:-c :" {} +
  make -j2 install

  cp -af include "$_PREFIX/"
  ln -sfh libunwind.a "$_PREFIX/lib/libunwind-$(uname -m).a"
fi
