#!/usr/bin/env bash
# Usage: ./update-tap-formula.sh <formula_name> <new_tag>

set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <formula_name> <new_tag>"
    exit 1
fi

FORMULA_NAME="$1"
NEW_TAG="$2"
TAP_DIR="$(brew --prefix)/Library/Taps/elfsundae/homebrew-homebrew/Formula"  # adjust if your tap is elsewhere
FORMULA_FILE="$TAP_DIR/$FORMULA_NAME.rb"

# Ensure formula file exists
if [[ ! -f "$FORMULA_FILE" ]]; then
    echo "Error: Formula file $FORMULA_FILE does not exist." >&2
    exit 1
fi

# Compute GitHub tarball URL
REPO_NAME="$FORMULA_NAME"  # assumes repo name = formula name, adjust if different
GITHUB_USER="ElfSundae"
URL="https://github.com/$GITHUB_USER/$REPO_NAME/archive/refs/tags/$NEW_TAG.tar.gz"

# Download tarball temporarily to compute sha256
TMP_TARBALL=$(mktemp)
trap 'rm -f "$TMP_TARBALL"' EXIT
curl -fL -o "$TMP_TARBALL" "$URL"
SHA256=$(shasum -a 256 "$TMP_TARBALL" | awk '{print $1}')

# Update formula file: url and sha256
sed -i '' -E "s|^  url .*|  url \"$URL\"|" "$FORMULA_FILE"
sed -i '' -E "s|^  sha256 .*|  sha256 \"$SHA256\"|" "$FORMULA_FILE"

echo "Updated $FORMULA_NAME.rb to tag $NEW_TAG with sha256 $SHA256"

# Run Homebrew audit
echo "Running brew audit..."
HOMEBREW_NO_INSTALL_FROM_API=1 brew audit "$FORMULA_NAME"

# Install formula from source
echo "Installing formula from source..."
HOMEBREW_NO_INSTALL_FROM_API=1 brew install --build-from-source --verbose --debug "$FORMULA_NAME"

# Run brew test
echo "Testing formula..."
HOMEBREW_NO_INSTALL_FROM_API=1 brew test "$FORMULA_NAME"
