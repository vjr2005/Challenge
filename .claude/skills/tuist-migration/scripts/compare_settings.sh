#!/bin/zsh
# compare_settings.sh — Generates comparison data between both projects
set -euo pipefail

ORIGINAL_WS="ProyectoOriginal.xcworkspace"   # ← Adjust
TUIST_WS="NombreApp-Tuist.xcworkspace"        # ← Adjust
ORIGINAL_PROJ="NombreApp.xcodeproj"            # ← Adjust
TUIST_PROJ="NombreApp-Tuist.xcodeproj"        # ← Adjust
OUT="/tmp/tuist-validation"
rm -rf "$OUT" && mkdir -p "$OUT"/{original,tuist,migration}

echo "=== 1. Orphan settings (tuist migration check-empty-settings) ==="
mise x -- tuist migration check-empty-settings \
  -p "$ORIGINAL_PROJ" > "$OUT/migration/check_empty_settings.txt" 2>&1 || true

echo "=== 2. Targets by dependency ==="
mise x -- tuist migration list-targets \
  -p "$ORIGINAL_PROJ" > "$OUT/migration/targets_original.txt" 2>&1 || true
mise x -- tuist migration list-targets \
  -p "$TUIST_PROJ" > "$OUT/migration/targets_tuist.txt" 2>&1 || true
diff "$OUT/migration/targets_original.txt" "$OUT/migration/targets_tuist.txt" \
  > "$OUT/migration/targets_diff.txt" 2>&1 || true

echo "=== 3. Build settings per scheme (original project) ==="
for scheme in $(xcodebuild -list -workspace "$ORIGINAL_WS" 2>/dev/null \
  | sed -n '/Schemes:/,/^$/p' | tail -n +2 | sed '/^$/d' | xargs); do
  safe=$(echo "$scheme" | tr ' /' '--')
  xcodebuild -showBuildSettings -workspace "$ORIGINAL_WS" \
    -scheme "$scheme" > "$OUT/original/${safe}.txt" 2>/dev/null || true
done

echo "=== 4. Build settings per scheme (Tuist project) ==="
for scheme in $(xcodebuild -list -workspace "$TUIST_WS" 2>/dev/null \
  | sed -n '/Schemes:/,/^$/p' | tail -n +2 | sed '/^$/d' | xargs); do
  safe=$(echo "$scheme" | tr ' /' '--')
  xcodebuild -showBuildSettings -workspace "$TUIST_WS" \
    -scheme "$scheme" > "$OUT/tuist/${safe}.txt" 2>/dev/null || true
done

echo "=== 5. Project structure (xcdiff) ==="
if command -v xcdiff >/dev/null 2>&1; then
  xcdiff --old "$ORIGINAL_PROJ" --new "$TUIST_PROJ" --format json \
    > "$OUT/migration/xcdiff.json" 2>&1 || true
  xcdiff --old "$ORIGINAL_PROJ" --new "$TUIST_PROJ" --format console \
    > "$OUT/migration/xcdiff_console.txt" 2>&1 || true
else
  echo "xcdiff not installed. Install with: brew install xcdiff" \
    > "$OUT/migration/xcdiff.txt"
fi

echo "=== 6. Dependency graph ==="
mise x -- tuist graph --format json > "$OUT/migration/graph.json" 2>/dev/null || true
mise x -- tuist graph --format dot --output "$OUT/migration/graph.dot" 2>/dev/null || true

echo "=== Results in $OUT ==="
echo "Original: $(ls "$OUT/original/" | wc -l) schemes exported"
echo "Tuist:    $(ls "$OUT/tuist/" | wc -l) schemes exported"
