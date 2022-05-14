#!/bin/bash
set -xe

_PKG=libunwind-35.3
_DEP_PKG=dyld-239.4
_PREFIX="$1"
_SCRATCH_DIR="$2"

if [[ ! -e "$_PREFIX/lib/libunwind.a" ]]
then
  cd "$_SCRATCH_DIR"

  for pkg in "$_PKG" "$_DEP_PKG" ; do
    [[ -s "$pkg.tar.gz" ]] || \
      curl -OkSL "https://github.com/apple-oss-distributions/${pkg%-*}/archive/$pkg.tar.gz"
    rm -rf "$pkg"
    tar -xf "$pkg.tar.gz" && mv "${pkg%-*}-$pkg" "$pkg"
  done

  cd "$_PKG"
  cp -pf "../$_DEP_PKG/include/mach-o/dyld_priv.h" include/mach-o/

  [[ -z "$MACOSX_DEPLOYMENT_TARGET" ]] || \
    _args="$_args MACOSX_DEPLOYMENT_TARGET=$MACOSX_DEPLOYMENT_TARGET"

  xcodebuild -jobs 2 -configuration Release -target dyld-libunwind.a \
    -project libunwind.xcodeproj DEBUG_INFORMATION_FORMAT= $_args

  # Install files
  cp -pf build/Release/libunwind.a "$_PREFIX/lib/"
  rm -f include/mach-o/dyld_priv.h && cp -af include "$_PREFIX/"
fi
