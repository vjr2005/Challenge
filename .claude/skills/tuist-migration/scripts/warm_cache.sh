#!/bin/zsh
# warm_cache.sh — Pre-compiles external dependencies into Tuist cache
set -euo pipefail

echo "=== 1. Installing dependencies ==="
mise x -- tuist install

echo "=== 2. Pre-compiling external dependency cache ==="
mise x -- tuist cache

echo "=== 3. Cache size ==="
CACHE_DIR="$(mise x -- tuist cache print-hashes 2>/dev/null | head -1 | xargs dirname 2>/dev/null || echo '')"
if [ -n "$CACHE_DIR" ] && [ -d "$CACHE_DIR" ]; then
  echo "Cache at: $CACHE_DIR"
  du -sh "$CACHE_DIR"
else
  echo "Tuist cache:"
  du -sh ~/Library/Caches/tuist 2>/dev/null || echo "(directory not found)"
fi

echo "=== Cache warm completed ==="
echo "Subsequent 'tuist generate' runs will use cached binaries"
echo "for external dependencies, avoiding recompilation."
