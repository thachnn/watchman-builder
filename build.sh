#!/bin/bash
set -xe
_SC_DIR="$(dirname "$0")"

_PREFIX=/usr/local
_SCRATCH_DIR="$(cd "$_SC_DIR/.."; pwd)"
_EXTRA_ARGS=-DENABLE_EDEN_SUPPORT=OFF

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
    _EXTRA_ARGS="$_EXTRA_ARGS -DINSTALL_WATCHMAN_STATE_DIR=ON"
    ;;
  --config-file=*)
    _EXTRA_ARGS="$_EXTRA_ARGS -DWATCHMAN_CONFIG_FILE=${1#*=}"
    ;;
  --unit-test)
    _NO_TESTS=0
    _EXTRA_ARGS="$_EXTRA_ARGS -DBUILD_TESTING=ON"
    ;;
  --with-os-libs)
    _WITH_OS_LIBS=1
    ;;
  *)
    echo "Usage: $0 [--prefix=$_PREFIX] [--without-python] [--with-os-libs]"
    echo "            [--state-dir=$_PREFIX/var/run/watchman] [--unit-test]"
    exit
    ;;
  esac
  shift
done

# Install build tools
. "$_SC_DIR/_install_cmake.sh"

# Watchman dependencies
"$_SC_DIR/_build_pcre.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_NO_TESTS"
"$_SC_DIR/_build_openssl.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_NO_TESTS"
"$_SC_DIR/_build_gflags.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_NO_TESTS"
[[ "$_WITH_OS_LIBS" != 1 ]] || \
  "$_SC_DIR/__build_libunwind.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_NO_TESTS"
"$_SC_DIR/_build_glog.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_NO_TESTS"
"$_SC_DIR/_build_libevent.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_NO_TESTS"
"$_SC_DIR/_build_fmt.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_NO_TESTS"

# Boost
"$_SC_DIR/__build_icu4c.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_NO_TESTS"
"$_SC_DIR/_build_boost.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_NO_TESTS" \
  'regex,thread,date_time,filesystem,system,chrono,context,atomic,program_options'

# GoogleTest
[[ "$_NO_TESTS" != 0 ]] || \
  "$_SC_DIR/_build_googletest.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_NO_TESTS"

# Folly
"$_SC_DIR/__build_double-conversion.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_NO_TESTS"
[[ "$_WITH_OS_LIBS" != 1 ]] || \
  "$_SC_DIR/__build_lzma.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_NO_TESTS"
"$_SC_DIR/__build_lz4.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_NO_TESTS"
"$_SC_DIR/__build_zstd.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_NO_TESTS"
"$_SC_DIR/__build_libsodium.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_NO_TESTS"
# Install modern Clang/LLVM
. "$_SC_DIR/__install_libcxx-headers.sh"
"$_SC_DIR/__build_snappy.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_NO_TESTS"
# NOTE: LibDwarf LibIberty LibAIO LibUring ?
"$_SC_DIR/_build_folly.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_NO_TESTS"


"$_SC_DIR/_build_watchman.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_EXTRA_ARGS" "$_NO_TESTS"
