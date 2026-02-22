#!/bin/zsh
# extract_cache_data.sh — Extracts dependency data to optimize cache
set -euo pipefail

OUT="/tmp/tuist-cache"
rm -rf "$OUT" && mkdir -p "$OUT"

echo "=== 1. Dependency graph ==="
mise x -- tuist graph --format json > "$OUT/graph.json"

echo "=== 2. Current Tuist/Package.swift ==="
cp Tuist/Package.swift "$OUT/Package.swift"

echo "=== 3. External (remote) dependencies ==="
# Extract remote dependency URLs from Package.swift
grep -E '\.package\(url:' Tuist/Package.swift \
  > "$OUT/external_deps.txt" 2>/dev/null || true

echo "=== 4. Current DerivedData size (reference) ==="
du -sh ~/Library/Developer/Xcode/DerivedData/ 2>/dev/null \
  > "$OUT/deriveddata_size.txt" || echo "No DerivedData" > "$OUT/deriveddata_size.txt"

echo "=== 5. Targets from the graph ==="
# Extract target names so the AI can identify which ones are external
python3 -c "
import json, sys
with open('$OUT/graph.json') as f:
    g = json.load(f)
for name, node in g.get('projects', {}).items():
    for target in node.get('targets', []):
        print(f\"{name}/{target}\")
" > "$OUT/all_targets.txt" 2>/dev/null || \
  echo "(manual parsing needed)" > "$OUT/all_targets.txt"

echo "=== Data extracted to $OUT ==="
echo "Files: $(find "$OUT" -type f | wc -l)"
