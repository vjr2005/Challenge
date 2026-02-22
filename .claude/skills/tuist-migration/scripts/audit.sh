#!/bin/zsh
# audit.sh — Full data collection for Tuist migration
set -euo pipefail

WORKSPACE="App.xcworkspace"       # ← Adjust to actual name
XCODEPROJ="NombreApp.xcodeproj"    # ← Adjust to actual name
OUT="/tmp/tuist-audit"
rm -rf "$OUT" && mkdir -p "$OUT"/{xcconfigs,build_settings,schemes,packages}

echo "=== 1. Extracting .xcconfig with tuist migration ==="
for target in $(mise x -- tuist migration list-targets -p "$XCODEPROJ" \
  | awk '{print $1}'); do
  mise x -- tuist migration settings-to-xcconfig \
    -p "$XCODEPROJ" -t "$target" \
    -x "$OUT/xcconfigs/${target}.xcconfig" 2>/dev/null || true
done
# Project-level settings
mise x -- tuist migration settings-to-xcconfig \
  -p "$XCODEPROJ" -x "$OUT/xcconfigs/Project.xcconfig"

echo "=== 2. Checking for orphan settings ==="
mise x -- tuist migration check-empty-settings \
  -p "$XCODEPROJ" > "$OUT/check_empty_settings.txt" 2>&1 || true

echo "=== 3. Target list by dependency ==="
mise x -- tuist migration list-targets \
  -p "$XCODEPROJ" > "$OUT/targets_by_dependency.txt"

echo "=== 4. Resolved build settings (all schemes x configs) ==="
schemes=($(xcodebuild -list -workspace "$WORKSPACE" 2>/dev/null \
  | sed -n '/Schemes:/,/^$/p' | tail -n +2 | sed '/^$/d' | xargs))
configs=($(xcodebuild -list -workspace "$WORKSPACE" 2>/dev/null \
  | sed -n '/Build Configurations:/,/^$/p' | tail -n +2 | sed '/^$/d' | xargs))

for scheme in "${schemes[@]}"; do
  for config in "${configs[@]}"; do
    safe=$(echo "${scheme}_${config}" | tr ' /' '--')
    xcodebuild -showBuildSettings \
      -workspace "$WORKSPACE" \
      -scheme "$scheme" \
      -configuration "$config" \
      > "$OUT/build_settings/${safe}.txt" 2>/dev/null || true
  done
done

echo "=== 5. Info.plist ==="
for plist in $(find . -name "Info.plist" -not -path "*/DerivedData/*" \
  -not -path "*/.build/*"); do
  safe=$(echo "$plist" | tr '/' '_' | sed 's/^_\.//')
  plutil -convert json -o "$OUT/${safe}.json" "$plist"
done

echo "=== 6. Schemes ==="
cp -r "$WORKSPACE"/xcshareddata/xcschemes/ "$OUT/schemes/" 2>/dev/null || true
cp -r "$XCODEPROJ"/xcshareddata/xcschemes/ "$OUT/schemes/" 2>/dev/null || true

echo "=== 7. Package.swift for each module ==="
find . -name "Package.swift" -not -path "*/.build/*" -not -path "*/Tuist/*" \
  | while read pkg; do
    safe=$(echo "$pkg" | tr '/' '_' | sed 's/^_\.//')
    cp "$pkg" "$OUT/packages/${safe}"
done

echo "=== 8. Entitlements ==="
find . -name "*.entitlements" -exec cp {} "$OUT/" \;

echo "=== 9. Directory structure ==="
find . -type f -name "*.swift" -o -name "*.xcassets" -o -name "*.storyboard" \
  -o -name "*.xib" -o -name "*.json" -o -name "*.strings" \
  -o -name "*.xcstrings" -o -name "*.lottie" \
  | grep -v DerivedData | grep -v .build \
  | sort > "$OUT/file_tree.txt"

echo "=== 10. Build phases (scripts) ==="
# Extract Run Script phases from pbxproj
ruby -e '
  pbx = File.read(ARGV[0])
  pbx.scan(/\/\* ShellScript \*\/.*?shellScript = "(.*?)";/m).each { |m|
    puts "---SCRIPT---"
    puts m[0].gsub(%q(\\n), "\n").gsub(%q(\\"), %q("))
  }
' "$XCODEPROJ/project.pbxproj" > "$OUT/build_phase_scripts.txt" 2>/dev/null || true

echo "=== Audit complete in $OUT ==="
echo "Generated files: $(find "$OUT" -type f | wc -l)"
