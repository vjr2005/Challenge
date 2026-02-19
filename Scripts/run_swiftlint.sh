#!/bin/bash

# SwiftLint runner script (Xcode build phase)

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

LINT_PATH="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_PATH="${SCRIPT_DIR}/../.swiftlint.yml"

if command -v mise >/dev/null 2>&1; then
    mise x -- swiftlint lint --config "$CONFIG_PATH" "$LINT_PATH"
else
    echo "warning: mise not installed. Run ./setup.sh to install."
fi
