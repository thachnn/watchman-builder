#!/bin/bash
set -xe
_SC_DIR="$(cd "`dirname "$0"`"; pwd)"

_PREFIX=/usr/local
_SCRATCH_DIR="$_SC_DIR/.."
_EXTRA_ARGS=

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
    _EXTRA_ARGS="$_EXTRA_ARGS -DWITHOUT_PYTHON=ON"
    ;;
  --state-dir=*)
    _EXTRA_ARGS="$_EXTRA_ARGS -DWATCHMAN_STATE_DIR=${1#*=}"
    ;;
  --config-file=*)
    _EXTRA_ARGS="$_EXTRA_ARGS -DWATCHMAN_CONFIG_FILE=${1#*=}"
    ;;
  --no-tests)
    _NO_TESTS=1
    _EXTRA_ARGS="$_EXTRA_ARGS -DBUILD_TESTING=OFF"
    ;;
  *)
    echo "Usage: $0 [--prefix=$_PREFIX] [--without-python] [--no-tests]"
    echo "            [--state-dir=$_PREFIX/var/run/watchman] [--with-lzma]"
    exit
    ;;
  esac
  shift
done

# Install dependencies
"$_SC_DIR/_build_pcre.sh" "$_PREFIX" "$_SCRATCH_DIR"
"$_SC_DIR/_build_openssl.sh" "$_PREFIX" "$_SCRATCH_DIR"
# TODO: LibEvent

# Gflags
# Glog
# fmt

# Boost (context thread)
# folly

# [[ "$_NO_TESTS" == 1 ]] || GMock / GTest / GoogleTest


# "$_SC_DIR/_build_watchman.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_EXTRA_ARGS" "$_NO_TESTS"
