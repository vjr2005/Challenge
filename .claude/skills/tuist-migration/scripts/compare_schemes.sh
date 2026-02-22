#!/bin/zsh
# compare_schemes.sh — Compares schemes between original project and Tuist
set -euo pipefail

ORIGINAL="ProyectoOriginal.xcworkspace"  # ← Adjust
TUIST="NombreApp-Tuist.xcworkspace"       # ← Adjust
OUT="/tmp/tuist-schemes"
rm -rf "$OUT" && mkdir -p "$OUT"

echo "=== 1. Schemes from the original project ==="
xcodebuild -list -workspace "$ORIGINAL" > "$OUT/original_list.txt" 2>/dev/null
# Extract only scheme names, one per line
sed -n '/Schemes:/,/^$/p' "$OUT/original_list.txt" \
  | tail -n +2 | sed '/^$/d' | xargs -I{} echo "{}" \
  | sort > "$OUT/original_schemes.txt"

echo "=== 2. Schemes from the Tuist project ==="
xcodebuild -list -workspace "$TUIST" > "$OUT/tuist_list.txt" 2>/dev/null
sed -n '/Schemes:/,/^$/p' "$OUT/tuist_list.txt" \
  | tail -n +2 | sed '/^$/d' | xargs -I{} echo "{}" \
  | sort > "$OUT/tuist_schemes.txt"

echo "=== 3. Configurations from the original project ==="
sed -n '/Build Configurations:/,/^$/p' "$OUT/original_list.txt" \
  | tail -n +2 | sed '/^$/d' > "$OUT/original_configs.txt"

echo "=== 4. Configurations from the Tuist project ==="
sed -n '/Build Configurations:/,/^$/p' "$OUT/tuist_list.txt" \
  | tail -n +2 | sed '/^$/d' > "$OUT/tuist_configs.txt"

echo "=== 5. Schemes diff ==="
diff "$OUT/original_schemes.txt" "$OUT/tuist_schemes.txt" \
  > "$OUT/schemes_diff.txt" 2>&1 || true

echo "=== 6. Configurations diff ==="
diff "$OUT/original_configs.txt" "$OUT/tuist_configs.txt" \
  > "$OUT/configs_diff.txt" 2>&1 || true

echo "=== Results in $OUT ==="
echo "Original: $(wc -l < "$OUT/original_schemes.txt") schemes"
echo "Tuist:    $(wc -l < "$OUT/tuist_schemes.txt") schemes"
if [ -s "$OUT/schemes_diff.txt" ]; then
  echo "DIFFERENCES FOUND — see $OUT/schemes_diff.txt"
else
  echo "Schemes match"
fi
