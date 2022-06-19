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
git clone --depth=1 -b v2022_05_16 https://github.com/thachnn/watchman-builder.git
cd watchman-builder

./build.sh --prefix=/opt/local --scratch-path=/usr/local/src \
  --without-python --state-dir=/usr/local/var/run/watchman --with-os-libs

# Pack the built
cd /opt/local && zip -r ~/watchman-2022.05.16-macos.zip bin/watchman*
cd /usr/local && zip -ru ~/watchman-2022.05.16-macos.zip var/run/watchman*
```

## Note

- To run Folly/Watchman unit-tests, just build with `--unit-test` option
```bash
./build.sh --prefix=/opt/local --scratch-path=/usr/local/src \
  --without-python --state-dir=/usr/local/var/run/watchman --with-os-libs --unit-test
```
