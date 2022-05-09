#!/bin/bash
set -xe
_SC_DIR="$(cd "`dirname "$0"`"; pwd)"

_PREFIX=/usr/local
_SCRATCH_DIR="$_SC_DIR/.."
_EXTRA_ARGS=--without-ruby

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
  --prefix=*)
    _PREFIX="${1#*=}"
    ;;
  --scratch-path=*)
    _SCRATCH_DIR="${1#*=}"
    ;;
  --without-python)
    _EXTRA_ARGS="$_EXTRA_ARGS --without-python"
    ;;
  --with-openssl)
    _SSL_LIB=1
    ;;
  --without-pcre)
    _PCRE_LIB=0
    _EXTRA_ARGS="$_EXTRA_ARGS --without-pcre"
    ;;
  --state-dir=*)
    _EXTRA_ARGS="$_EXTRA_ARGS --enable-statedir=${1#*=}"
    ;;
  --config-file=*)
    _EXTRA_ARGS="$_EXTRA_ARGS --enable-conffile=${1#*=}"
    ;;
  *)
    echo "Usage: $0 [--prefix=$_PREFIX] [--without-python] [--with-openssl]"
    echo "            [--without-pcre] [--state-dir=$_PREFIX/var/run/watchman]"
    exit
    ;;
  esac
  shift
done

# Install dependencies
[[ "$_SSL_LIB" != 1 ]] || "$_SC_DIR/_build_openssl.sh" "$_PREFIX" "$_SCRATCH_DIR"
[[ "$_PCRE_LIB" == 0 ]] || "$_SC_DIR/_build_pcre.sh" "$_PREFIX" "$_SCRATCH_DIR"

# Prepare build arguments
[[ ! -x "$_PREFIX/bin/pcre-config" -o "$_PCRE_LIB" == 0 ]] || \
  _EXTRA_ARGS="$_EXTRA_ARGS --with-pcre=$_PREFIX/bin/pcre-config"
[[ "$_SSL_LIB" != 1 -a "$_PCRE_LIB" == 0 ]] || \
  _EXTRA_ARGS="$_EXTRA_ARGS CPPFLAGS=-I$_PREFIX/include LDFLAGS=-L$_PREFIX/lib"

"$_SC_DIR/_build_watchman.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_EXTRA_ARGS"
