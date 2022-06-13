#!/bin/bash
set -xe
_SC_DIR="$(cd "`dirname "$0"`"; pwd)"

_VER=1_78_0
_PKG="boost_$_VER"
_PREFIX="$1"
_SCRATCH_DIR="$2"
_NO_TESTS="$3"
_LIBRARIES="$4"

# Depends on: ICU (lzma zstd: iostreams)
if [[ ! -e "$_PREFIX/include/boost" ]]
then
  cd "$_SCRATCH_DIR"
  while ! shasum -cs <<< "8681f175d4bdb26c52222665793eef08490d7758529330f98d3b29dd0735bccc *$_PKG.tar.bz2"
  do
    curl -OkfSL "https://boostorg.jfrog.io/artifactory/main/release/${_VER//_/.}/source/$_PKG.tar.bz2"
  done
  rm -rf "$_PKG"
  (set +x; while sleep 2; do echo -n .; done) & tar -xf "$_PKG.tar.bz2" && kill -9 $!

  cd "$_PKG"
  # Patch tests
  patch -p1 -i "$_SC_DIR/boost.patch"

  # Disable debugging symbols
  echo "using darwin : : ${CXX} : <compileflags>-g0 ;" > user-config.jam
  ./bootstrap.sh "--prefix=$_PREFIX" "--with-icu=$_PREFIX" "--with-libraries=$_LIBRARIES"

  # Fix slow headers copying
  rsync -aW --include='*.'{hpp,h,ipp,inc} --exclude='*.*' boost "$_PREFIX/include"

  # Clang compiler may need `cxxflags=-stdlib=libc++ linkflags=-stdlib=libc++`
  ./b2 -d2 -j2 --user-config=user-config.jam variant=release cxxflags=-std=c++14 install \
    threading=multi link=static "include=$_PREFIX/include" "library-path=$_PREFIX/lib"

  if [[ "$_NO_TESTS" == 0 ]]; then
    cd status
    ../b2 -j2 -q "--include-tests=$_LIBRARIES" --user-config=../user-config.jam variant=release \
      cxxflags=-std=c++14 threading=multi link=static "include=$_PREFIX/include" "library-path=$_PREFIX/lib"
  fi
fi
