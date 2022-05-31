#!/bin/bash
set -xe

_PKG=boost_1_69_0
_PREFIX="$1"
_SCRATCH_DIR="$2"
_LIBRARIES="$3"

# Depends on: ICU (lzma zstd: iostreams)
if [[ ! -e "$_PREFIX/include/boost" ]]
then
  cd "$_SCRATCH_DIR"
  while ! shasum -cs <<< "8f32d4617390d1c2d16f26a27ab60d97807b35440d45891fa340fc2648b04406 *$_PKG.tar.bz2"
  do
    curl -OkfSL "https://boostorg.jfrog.io/artifactory/main/release/$(tr _ . <<< "${_PKG:6}")/source/$_PKG.tar.bz2"
  done
  rm -rf "$_PKG"
  tar -xf "$_PKG.tar.bz2"

  cd "$_PKG"
  # Disable debugging symbols
  echo "using darwin : : ${CXX} : <compileflags>-g0 ;" > user-config.jam
  ./bootstrap.sh "--prefix=$_PREFIX" "--with-icu=$_PREFIX" "--with-libraries=$_LIBRARIES"

  # Fix slow headers copying
  rsync -aW --include='*.'{hpp,h,ipp,inc} --exclude='*.*' boost "$_PREFIX/include"

  # Clang compiler may need `cxxflags=-stdlib=libc++ linkflags=-stdlib=libc++`
  ./b2 -d2 -j2 --user-config=user-config.jam variant=release cxxflags=-std=c++14 install \
    threading=multi link=static "include=$_PREFIX/include" "library-path=$_PREFIX/lib"
fi
