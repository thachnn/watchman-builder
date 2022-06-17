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

- To run Folly/Watchman unit-tests on old macOS (<= 10.12), just install modern Clang/LLVM,
  then use it to re-build with `--unit-test` option
```bash
curl -OkfSL https://github.com/llvm/llvm-project/releases/download/llvmorg-9.0.1/clang+llvm-9.0.1-x86_64-apple-darwin.tar.xz
tar -C /usr/local/opt -xf clang+llvm-*-x86_64-*.tar.xz

mv /usr/local/opt/clang+llvm-*-x86_64-* /usr/local/opt/llvm
sed -i- 's/\(macos[^ =]*,introduced\)=1[0-3][0-9.]*/\1=10.9/' /usr/local/opt/llvm/include/c++/v1/__config

export PATH="/usr/local/opt/llvm/bin:${PATH}"
./build.sh --prefix=/opt/local --scratch-path=/usr/local/src \
  --without-python --state-dir=/usr/local/var/run/watchman --with-os-libs --unit-test
```
