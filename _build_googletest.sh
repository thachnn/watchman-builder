#!/bin/bash
set -xe

_PKG=googletest-release-1.10.0
_PREFIX="$1"
_SCRATCH_DIR="$2"
_NO_TESTS="$3"

if [[ ! -e "$_PREFIX/lib/cmake/GTest" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tgz" ]] || \
    curl -o "$_PKG.tgz" -kfSL "https://github.com/google/googletest/archive/${_PKG#*-}.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tgz"

  cd "$_PKG"
  # Optimize .pc files
  sed -i- 's/^prefix=\$.*/prefix=@CMAKE_INSTALL_PREFIX@/' */cmake/*.pc.in

  cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_FIND_FRAMEWORK=LAST \
    -DCMAKE_VERBOSE_MAKEFILE=ON -Wno-dev "-DCMAKE_INSTALL_PREFIX=$_PREFIX" \
    -Dg{mock,test}_build_tests=$([[ "$_NO_TESTS" == 0 ]] && echo ON || echo OFF)
  # -DBUILD_SHARED_LIBS=OFF

  # Use relative paths
  for d in google{mock,test}; do
    find "$d/CMakeFiles" -name flags.make -exec sed -i- -e "s|$PWD/$d|.|g;s|$PWD/|../|g" {} + \
      -o -name build.make -exec sed -i- -e "s|-c $PWD/$d/|-c |;s|-c $PWD/|-c ../|" {} +
  done

  make -j2 install
  [[ "$_NO_TESTS" != 0 ]] || make test
fi
