#!/bin/bash
set -xe
_SC_DIR="$(cd "`dirname "$0"`"; pwd)"

_PKG=libunwind-35.3
_BASE_URL=https://github.com/apple-oss-distributions
_PREFIX="$1"
_SCRATCH_DIR="$2"

if [[ ! -e "$_PREFIX/lib/libunwind.a" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tar.gz" ]] || curl -OkSL "$_BASE_URL/libunwind/archive/$_PKG.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tar.gz" && mv "libunwind-$_PKG" "$_PKG"

  cd "$_PKG"
  # Patch to create Makefile
  patch -p1 -i "$_SC_DIR/libunwind.patch"

  # Missing headers
  _DEPS=(dyld-239.4 libpthread-105.1.4 xnu-2422.115.4)
  curl -o include/mach-o/dyld_priv.h -kfSL \
    "$_BASE_URL/dyld/raw/${_DEPS[0]}/include/mach-o/dyld_priv.h"

  # Missing headers for shared library
  #mkdir -p include/{pthread,os,System/machine}
  #curl -o include/System/pthread_machdep.h -kfSL \
  #  "$_BASE_URL/libpthread/raw/${_DEPS[1]}/private/tsd_private.h"
  #curl -o include/pthread/spinlock_private.h -kfSL \
  #  "$_BASE_URL/libpthread/raw/${_DEPS[1]}/private/spinlock_private.h"
  #curl -o include/System/machine/cpu_capabilities.h -kfSL \
  #  "$_BASE_URL/xnu/raw/${_DEPS[2]}/osfmk/i386/cpu_capabilities.h"
  #curl -o include/os/tsd.h -kfSL "$_BASE_URL/xnu/raw/${_DEPS[2]}/libsyscall/os/tsd.h"

  make -j2 V=1 install-static install-includes "PREFIX=$_PREFIX" RELEASE=1
fi
