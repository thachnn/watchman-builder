#!/bin/sh
find /Library/Developer/CommandLineTools/usr \
     /Applications/Xcode.app/Contents/Developer/Toolchains \
  -regex '.*/clang/[0-9][^/]*' -exec basename {} \; -quit 2> /dev/null
