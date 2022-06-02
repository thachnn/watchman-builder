#!/bin/bash
set -xe

_PKG=glog-0.4.0
_PREFIX="$1"
_SCRATCH_DIR="$2"
_NO_TESTS="$3"

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
    -DCMAKE_VERBOSE_MAKEFILE=ON -Wno-dev "-DCMAKE_INSTALL_PREFIX=$_PREFIX" \
    "-DCMAKE_PREFIX_PATH=$_PREFIX" -DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON \
    -DBUILD_TESTING=$([[ "$_NO_TESTS" == 0 ]] && echo ON || echo OFF)

  # Use relative paths
  find CMakeFiles -name build.make -exec sed -i- "s:-c $PWD/:-c :" {} +
  make -j2 install

  # Generate .pc files
  mkdir -p "$_PREFIX/lib/pkgconfig"
  sed -e "s:@prefix@:$_PREFIX:" -e 's/@exec_prefix@/${prefix}/' \
    -e 's,@libdir@,${exec_prefix}/lib,;s,@includedir@,${prefix}/include,' \
    -e "s/@VERSION@/${_PKG#*-}/" libglog.pc.in > "$_PREFIX/lib/pkgconfig/libglog.pc"

  [[ "$_NO_TESTS" != 0 ]] || make test
fi
