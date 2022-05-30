#!/bin/bash
set -xe

_PKG=glog-0.5.0
_PREFIX="$1"
_SCRATCH_DIR="$2"

# Depends on: gflags
if [[ ! -e "$_PREFIX/lib/cmake/glog" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tgz" ]] || \
    curl -o "$_PKG.tgz" -kfSL "https://github.com/google/glog/archive/v${_PKG#*-}.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tgz"

  cd "$_PKG"
  cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_FIND_FRAMEWORK=LAST \
    -DCMAKE_VERBOSE_MAKEFILE=ON -Wno-dev -DBUILD_TESTING=OFF -DBUILD_SHARED_LIBS=OFF \
    "-DCMAKE_INSTALL_PREFIX=$_PREFIX" "-DCMAKE_PREFIX_PATH=$_PREFIX" \
    -DWITH_GTEST=OFF -DWITH_PKGCONFIG=ON -DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON

  # Use relative paths
  find CMakeFiles -name build.make -exec sed -i- "s:-c $PWD/:-c :" {} +
  find CMakeFiles -name flags.make -exec sed -i- "s:$PWD/::g" {} +

  make -j2 install
  # Correct .pc file
  sed -i '' "s|=$_PREFIX/|=\${prefix}/|" "$_PREFIX/lib/pkgconfig/libglog.pc"
fi
