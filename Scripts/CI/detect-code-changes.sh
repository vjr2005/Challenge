#!/bin/bash

# Decides whether a pull request changes anything other than documentation.
#
# Input (stdin): changed file paths, one per line.
# Output (stdout): "true" when at least one path is not documentation, "false" otherwise.
#
# Documentation is `*.md`, `docs/**` and `.claude/**`; none of it is read by the build or the tests.
# Everything else counts as code, including `.github/**`, so CI changes always run the full pipeline.
# An empty list prints "true": when in doubt, run everything.

set -euo pipefail

found_any=false

while IFS= read -r path; do
    [ -z "$path" ] && continue
    found_any=true
    case "$path" in
        *.md | docs/* | .claude/*) ;;
        *)
            echo true
            exit 0
            ;;
    esac
done

if [ "$found_any" = true ]; then
    echo false
else
    echo true
fi
