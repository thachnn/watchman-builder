#!/bin/bash
set -xe

: "${_PREFIX:=$1}"
: "${_SCRATCH_DIR:=$2}"

if ! command -v cargo &> /dev/null
then
  if [[ ! -x "$_PREFIX/rust/bin/cargo" ]]
  then
  (
    _PKG=rust-1.59.0-x86_64-apple-darwin

    cd "$_SCRATCH_DIR"
    while ! shasum -cs <<< "e40cd4b7bacf2e4c5e2c021863aa1c3028599cea9e9d551b7d244382f3b55b9e *$_PKG.pkg"
    do
      curl -OkfSL "https://static.rust-lang.org/dist/$_PKG.pkg"
    done

    # Install automatically
    #echo '<plist version="1.0"><array><dict></dict></array></plist>' > "$TMPDIR/rust-choices.xml"
    #sudo installer -pkg "$_PKG.pkg" -target / -applyChoiceChangesXML "$TMPDIR/rust-choices.xml"

    # Install manually
    mkdir -p "$_PKG" "$_PREFIX/rust"
    xar -C "$_PKG" -xf "$_PKG.pkg" {rustc,rust-std,cargo}.pkg/Scripts
    find "$_PKG" -type f -exec tar -C "$_PREFIX/rust" --strip-components=2 --exclude=manifest.in -xf "{}" \;
    rm -rf "$_PKG"
  )
  fi

  export PATH="$_PREFIX/rust/bin:$PATH"
fi
