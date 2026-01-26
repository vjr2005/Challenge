#!/bin/bash

# SwiftLint runner script (Xcode build phase)

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

LINT_PATH="${1:-.}"

if command -v mise >/dev/null 2>&1; then
    mise x -- swiftlint lint --config "${SRCROOT}/.swiftlint.yml" "$LINT_PATH"
else
    echo "warning: mise not installed. Run ./setup.sh to install."
fi
