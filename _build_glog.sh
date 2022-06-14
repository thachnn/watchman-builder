#!/bin/bash
set -xe

_PKG=glog-0.5.0
_PREFIX="$1"
_SCRATCH_DIR="$2"
_NO_TESTS="$3"

# Depends on: gflags, libunwind
if [[ ! -e "$_PREFIX/lib/cmake/glog" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tgz" ]] || \
    curl -o "$_PKG.tgz" -kfSL "https://github.com/google/glog/archive/v${_PKG#*-}.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tgz"

  cd "$_PKG"
  cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_FIND_FRAMEWORK=LAST \
    -DCMAKE_VERBOSE_MAKEFILE=ON -Wno-dev "-DCMAKE_INSTALL_PREFIX=$_PREFIX" \
    -DWITH_PKGCONFIG=ON "-DCMAKE_PREFIX_PATH=$_PREFIX" -DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON \
    -DBUILD_SHARED_LIBS=OFF -DBUILD_TESTING=$([[ "$_NO_TESTS" == 0 ]] && echo ON || echo OFF)

  # Use relative paths
  find CMakeFiles -name flags.make -exec sed -i- "s:$PWD/::g" {} + \
    -o -name build.make -exec sed -i- "s:-c $PWD/:-c :" {} +

  make -j2 install
  # Correct .pc file
  sed -i '' "s|=$_PREFIX/|=\${prefix}/|" "$_PREFIX/lib/pkgconfig/libglog.pc"

  if [[ "$_NO_TESTS" == 0 ]]; then
    sed -i- 's/(at runtime)" " new/(at runtime); new/' CTestTestfile.cmake
    make test || true
  fi
fi
