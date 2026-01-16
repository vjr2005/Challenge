#!/bin/bash

# SwiftLint runner script

# Add common tool paths (mise, Homebrew)
export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:/usr/local/bin:$PATH"

LINT_PATH="${1:-.}"

if command -v swiftlint >/dev/null 2>&1; then
    swiftlint lint --config "${SRCROOT}/.swiftlint.yml" "$LINT_PATH"
else
    echo "warning: SwiftLint not installed. Run ./setup.sh to install."
fi
