# Watchman builder

Provide a simple way to build [Watchman](https://github.com/facebook/watchman) from source on macOS.

## Prerequisites

- Install `Xcode` / `Command Line Tools` (from `xcode-select --install`)

- Setup environment variables:
```bash
export PATH="/Library/Developer/CommandLineTools/usr/bin:${PATH}"
export CC=clang
export CXX=clang++
```

## Usage

```bash
# Use the stable release
git clone --depth=1 -b v4_9_0 https://github.com/thachnn/watchman-builder.git
cd watchman-builder

./build.sh --prefix=/opt/local --scratch-path=/usr/local/src \
  --without-python --with-openssl --state-dir=/usr/local/var/run/watchman

# Pack the built
cd /opt/local && zip -r ~/watchman-4.9.0-macos.zip bin/watchman* share/doc/watchman*
cd /usr/local && zip -ru ~/watchman-4.9.0-macos.zip var/run/watchman*
```
