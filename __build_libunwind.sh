#!/bin/bash
set -xe
_SC_DIR="$(cd "`dirname "$0"`"; pwd)"

_PKG=libunwind-9.0.0.src
_PREFIX="$1"
_SCRATCH_DIR="$2"
_NO_TESTS="$3"

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
  tar -C "$_PKG" -xf "$_DEP.tar.xz" --strip-components=1 "$_DEP/cmake/modules" "$_DEP/utils/lit"

  cd "$_PKG"
  # Disable tests
  sed -i- $'s/^ *add_subdirectory(test)/if (LLVM_INCLUDE_TESTS)\\\n&\\\nendif()/' CMakeLists.txt
  sed -i- -e $'s/^include(AddLLVM)/include(FindPythonInterp)\\\nfind_package(Python3)\\\n&/' \
    -e 's/^set(LIBUNWIND_LIBCXX_PATH [^)]*/& CACHE STRING "libcxx source"/' test/CMakeLists.txt

  cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_FIND_FRAMEWORK=LAST \
    -DCMAKE_VERBOSE_MAKEFILE=ON -Wno-dev "-DCMAKE_INSTALL_PREFIX=$_PREFIX" \
    "-DLLVM_PATH=$PWD" "-DLLVM_EXTERNAL_LIT=$PWD/utils/lit/lit.py" "-DLIBUNWIND_LIBCXX_PATH=$PWD" \
    -DLIBUNWIND_ENABLE_SHARED=OFF -DLLVM_INCLUDE_TESTS=$([[ "$_NO_TESTS" == 0 ]] && echo ON || echo OFF)

  # Use relative paths
  find */CMakeFiles -name build.make -exec sed -i- "s:-c $PWD/[^ /]*/:-c :" {} +

  make -j2 install
  cp -af include "$_PREFIX"

  if [[ "$_NO_TESTS" == 0 ]]; then
    cd ..
    _DEP="libcxx-${_PKG#*-}"
    [[ -s "$_DEP.tar.xz" ]] || "$_SC_DIR/download_llvm_pkg.sh" "$_DEP" "$_VER"
    tar -C "$_PKG" -xf "$_DEP.tar.xz" --strip-components=1 '--exclude=*.cpp' \
      "$_DEP/utils"/{libcxx,*.py} "$_DEP/test"/{std/input.output/filesystems,support}

    cd "$_PKG"
    make check-unwind || true
  fi
fi
