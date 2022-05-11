#!/bin/bash
set -xe

_PKG=glog-0.4.0
_PREFIX="$1"
_SCRATCH_DIR="$2"

if [[ ! -e "$_PREFIX/lib/cmake/glog" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tgz" ]] || \
    curl -o "$_PKG.tgz" -kSL "https://github.com/google/glog/archive/v${_PKG#*-}.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tgz"

  cd "$_PKG"
  CMAKE_PREFIX_PATH="$_PREFIX" \
  cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_FIND_FRAMEWORK=LAST \
    -DCMAKE_VERBOSE_MAKEFILE=ON -Wno-dev -DBUILD_TESTING=OFF \
    "-DCMAKE_INSTALL_PREFIX=$_PREFIX" -DBUILD_SHARED_LIBS=OFF

  make -j2 install

  # Install missing files
  mkdir -p "$_PREFIX/lib/pkgconfig"
  sed -e "s:@prefix@:$_PREFIX:" -e 's,@includedir@,${prefix}/include,' \
    -e 's/@exec_prefix@/${prefix}/' -e 's,@libdir@,${exec_prefix}/lib,' \
    -e "s/@VERSION@/${_PKG#*-}/" libglog.pc.in > "$_PREFIX/lib/pkgconfig/libglog.pc"
fi
