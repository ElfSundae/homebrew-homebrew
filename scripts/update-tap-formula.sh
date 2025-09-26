#!/usr/bin/env bash
# Usage: ./update-tap-formula.sh <formula_name> <new_tag> [--repo=USER/REPO] [--url=URL]

set -euo pipefail

# Parse arguments: positional args are <formula_name> <new_tag>; optional flags:
#   --repo=USER/REPO   (e.g. --repo=ElfSundae/reponame)
#   --url=URL          (full tarball URL)
FORMULA_NAME=""
NEW_TAG=""
REPO_SPEC=""
URL=""
GITHUB_USER="ElfSundae"
REPO_NAME=""

for arg in "$@"; do
    case "$arg" in
        --repo=*) REPO_SPEC="${arg#--repo=}";;
        --url=*) URL="${arg#--url=}";;
        --help|-h)
            echo "Usage: $0 <formula_name> <new_tag> [--repo=USER/REPO] [--url=URL]"
            exit 0
            ;;
        *)
            if [[ -z "$FORMULA_NAME" ]]; then
                FORMULA_NAME="$arg"
            elif [[ -z "$NEW_TAG" ]]; then
                NEW_TAG="$arg"
            else
                echo "Unknown argument: $arg" >&2
                exit 1
            fi
            ;;
    esac
done

if [[ -z "$FORMULA_NAME" || -z "$NEW_TAG" ]]; then
    echo "Usage: $0 <formula_name> <new_tag> [--repo=USER/REPO] [--url=URL]" >&2
    exit 1
fi

# default repo/user
REPO_NAME="${FORMULA_NAME}"
if [[ -n "$REPO_SPEC" ]]; then
    if [[ "$REPO_SPEC" == */* ]]; then
        GITHUB_USER="${REPO_SPEC%%/*}"
        REPO_NAME="${REPO_SPEC#*/}"
    else
        REPO_NAME="$REPO_SPEC"
    fi
fi

if [[ -z "$URL" ]]; then
    URL="https://github.com/$GITHUB_USER/$REPO_NAME/archive/refs/tags/$NEW_TAG.tar.gz"
fi

TAP_DIR="$(brew --prefix)/Library/Taps/elfsundae/homebrew-homebrew/Formula"
FORMULA_FILE="$TAP_DIR/$FORMULA_NAME.rb"

# Ensure formula file exists
if [[ ! -f "$FORMULA_FILE" ]]; then
    echo "Error: Formula file $FORMULA_FILE does not exist." >&2
    exit 1
fi

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
