# Watchman builder

Provide a simple way to build [Watchman](https://github.com/facebook/watchman) from source on macOS.

## Prerequisites

- Install `Xcode` / `Command Line Tools` (from `xcode-select --install`)

- Setup environment variables:
```bash
export PATH="/Library/Developer/CommandLineTools/usr/bin:${PATH}"
export CC=clang
export CXX=clang++
export SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX10.14.sdk
```

## Usage

```bash
# Use the stable release
git clone --depth=1 -b v2021_02_15 https://github.com/thachnn/watchman-builder.git
cd watchman-builder

./build.sh --prefix=/opt/local --scratch-path=/usr/local/src \
  --without-python --state-dir=/usr/local/var/run/watchman --with-os-libs

# Pack the built
cd /opt/local && zip -r ~/watchman-2021.02.15-macos.zip bin/watchman*
cd /usr/local && zip -ru ~/watchman-2021.02.15-macos.zip var/run/watchman*
```

## Note

- To run Watchman unit-test on old macOS (<= 10.12), just build as normally, then install
  LLVM `libc++*.dylib` into target libdir (e.g. `/opt/local/lib`) and re-build with `--unit-test` option
```bash
curl -OkfSL https://releases.llvm.org/9.0.0/clang+llvm-9.0.0-x86_64-darwin-apple.tar.xz

tar -C /opt/local -xvf clang+llvm-9.0.0-x86_64-darwin-apple.tar.xz --strip-components=1 \
  clang+llvm-9.0.0-x86_64-darwin-apple/lib/{libc++abi.1.0,libc++abi.1,libc++abi,libc++.1.0,libc++.1,libc++}.dylib

./build.sh --prefix=/opt/local --scratch-path=/usr/local/src \
  --without-python --state-dir=/usr/local/var/run/watchman --unit-test
```
