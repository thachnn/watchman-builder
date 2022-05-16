#!/bin/bash
set -xe

: "${_PREFIX:=$1}"
: "${_SCRATCH_DIR:=$2}"

# Check missing C++17 headers
