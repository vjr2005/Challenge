#!/bin/zsh
# validate_migration.sh — End-to-end equivalence validation
set -uo pipefail

# === Configuration (adjust) ===
ORIGINAL_WS="ProyectoOriginal.xcworkspace"
TUIST_WS="NombreApp-Tuist.xcworkspace"
ORIGINAL_PROJ="NombreApp.xcodeproj"
TUIST_PROJ="NombreApp-Tuist.xcodeproj"
SCHEME="NombreApp"
TUIST_SCHEME="NombreApp (Dev)"
MODULE_TESTS_SCHEME="NombreAppModuleTests"
DESTINATION="iPhone 17 Pro"
OUT="/tmp/migration-validation"
SKIP_TESTS=false
TOLERANCE=10  # Binary size tolerance (+-%)

# Parse args
while [[ $# -gt 0 ]]; do
  case $1 in
    --skip-tests) SKIP_TESTS=true; shift ;;
    --output) OUT="$2"; shift 2 ;;
    --destination) DESTINATION="$2"; shift 2 ;;
    *) shift ;;
  esac
done

rm -rf "$OUT" && mkdir -p "$OUT"
PASS=0; WARN=0; FAIL=0
REPORT="$OUT/validation_report.txt"

# Colors
GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; NC='\033[0m'

print_result() {
  local check="$1" result="$2" detail="$3"
  case "$result" in
    PASS) color=$GREEN; ((PASS++)) ;;
    WARN) color=$YELLOW; ((WARN++)) ;;
    FAIL) color=$RED; ((FAIL++)) ;;
  esac
  printf "${color}%-8s${NC} %-35s %s\n" "[$result]" "$check" "$detail"
  echo "$result | $check | $detail" >> "$REPORT"
}

# Prerequisite check
for cmd in xcodebuild mise; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "ERROR: $cmd not found"; exit 1; }
done

echo "=== Migration validation ==="
echo "Date: $(date)" > "$REPORT"
echo "" >> "$REPORT"
START=$(date +%s)

# CHECK 1: Orphan settings
echo "--- CHECK 1: Orphan settings ---"
EMPTY_OUT=$(mise x -- tuist migration check-empty-settings -p "$ORIGINAL_PROJ" 2>&1 || true)
if echo "$EMPTY_OUT" | grep -qi "no settings"; then
  print_result "Orphan settings" "PASS" "None found"
else
  echo "$EMPTY_OUT" > "$OUT/check1_empty_settings.txt"
  print_result "Orphan settings" "WARN" "See check1_empty_settings.txt"
fi

# CHECK 2: Equivalent targets
echo "--- CHECK 2: Equivalent targets ---"
mise x -- tuist migration list-targets -p "$ORIGINAL_PROJ" 2>/dev/null \
  | sort > "$OUT/targets_original.txt"
mise x -- tuist migration list-targets -p "$TUIST_PROJ" 2>/dev/null \
  | sort > "$OUT/targets_tuist.txt"
if diff -q "$OUT/targets_original.txt" "$OUT/targets_tuist.txt" >/dev/null 2>&1; then
  print_result "Equivalent targets" "PASS" "Match"
else
  diff "$OUT/targets_original.txt" "$OUT/targets_tuist.txt" > "$OUT/check2_targets_diff.txt" || true
  print_result "Equivalent targets" "FAIL" "See check2_targets_diff.txt"
fi

# CHECK 3: Critical build settings
echo "--- CHECK 3: Critical build settings ---"
CRITICAL_SETTINGS="SWIFT_VERSION|SWIFT_DEFAULT_ACTOR_ISOLATION|SWIFT_APPROACHABLE_CONCURRENCY"
CRITICAL_SETTINGS+="|IPHONEOS_DEPLOYMENT_TARGET|CODE_SIGN_IDENTITY|DEVELOPMENT_TEAM"
CRITICAL_SETTINGS+="|PRODUCT_BUNDLE_IDENTIFIER|OTHER_LDFLAGS"
mkdir -p "$OUT"/settings_{original,tuist}
xcodebuild -showBuildSettings -workspace "$ORIGINAL_WS" -scheme "$SCHEME" 2>/dev/null \
  | grep -E "($CRITICAL_SETTINGS)" | sort > "$OUT/settings_original/critical.txt"
xcodebuild -showBuildSettings -workspace "$TUIST_WS" -scheme "$TUIST_SCHEME" 2>/dev/null \
  | grep -E "($CRITICAL_SETTINGS)" | sort > "$OUT/settings_tuist/critical.txt"
if diff -q "$OUT/settings_original/critical.txt" "$OUT/settings_tuist/critical.txt" >/dev/null 2>&1; then
  print_result "Critical build settings" "PASS" "Match"
else
  diff "$OUT/settings_original/critical.txt" "$OUT/settings_tuist/critical.txt" \
    > "$OUT/check3_settings_diff.txt" || true
  print_result "Critical build settings" "FAIL" "See check3_settings_diff.txt"
fi

# CHECK 4: Project structure (xcdiff)
echo "--- CHECK 4: Project structure ---"
if command -v xcdiff >/dev/null 2>&1; then
  xcdiff --old "$ORIGINAL_PROJ" --new "$TUIST_PROJ" --format json \
    > "$OUT/check4_xcdiff.json" 2>&1 || true
  print_result "Structure (xcdiff)" "WARN" "Manual review: check4_xcdiff.json"
else
  print_result "Structure (xcdiff)" "WARN" "xcdiff not installed (brew install xcdiff)"
fi

# CHECK 5: Dependency graph
echo "--- CHECK 5: Dependency graph ---"
mise x -- tuist graph --format json > "$OUT/check5_graph.json" 2>/dev/null || true
print_result "Dependency graph" "WARN" "Manual review: check5_graph.json"

# CHECK 6: Binary comparison
echo "--- CHECK 6: Binaries ---"
mkdir -p "$OUT"/{dd_original,dd_tuist}
xcodebuild build -workspace "$ORIGINAL_WS" -scheme "$SCHEME" \
  -configuration Release -destination "generic/platform=iOS Simulator" \
  -derivedDataPath "$OUT/dd_original" 2>&1 | tail -5
xcodebuild build -workspace "$TUIST_WS" -scheme "$TUIST_SCHEME" \
  -configuration Release -destination "generic/platform=iOS Simulator" \
  -derivedDataPath "$OUT/dd_tuist" 2>&1 | tail -5
# Compare embedded frameworks
ORIG_APP=$(find "$OUT/dd_original" -name "*.app" -type d | head -1)
TUIST_APP=$(find "$OUT/dd_tuist" -name "*.app" -type d | head -1)
if [ -n "$ORIG_APP" ] && [ -n "$TUIST_APP" ]; then
  ls "$ORIG_APP/Frameworks/" 2>/dev/null | sort > "$OUT/frameworks_original.txt"
  ls "$TUIST_APP/Frameworks/" 2>/dev/null | sort > "$OUT/frameworks_tuist.txt"
  if diff -q "$OUT/frameworks_original.txt" "$OUT/frameworks_tuist.txt" >/dev/null 2>&1; then
    # Compare binary size
    ORIG_SIZE=$(stat -f%z "$ORIG_APP/${SCHEME}" 2>/dev/null || echo 0)
    TUIST_SIZE=$(stat -f%z "$TUIST_APP/${SCHEME}" 2>/dev/null || echo 0)
    if [ "$ORIG_SIZE" -gt 0 ] && [ "$TUIST_SIZE" -gt 0 ]; then
      DIFF_PCT=$(( (TUIST_SIZE - ORIG_SIZE) * 100 / ORIG_SIZE ))
      ABS_DIFF=${DIFF_PCT#-}
      if [ "$ABS_DIFF" -le "$TOLERANCE" ]; then
        print_result "Binaries" "PASS" "Frameworks ok, size +-${ABS_DIFF}%"
      else
        print_result "Binaries" "WARN" "Size differs +-${ABS_DIFF}% (tolerance: +-${TOLERANCE}%)"
      fi
    else
      print_result "Binaries" "WARN" "Could not compare size"
    fi
  else
    diff "$OUT/frameworks_original.txt" "$OUT/frameworks_tuist.txt" \
      > "$OUT/check6_frameworks_diff.txt" || true
    print_result "Binaries" "FAIL" "Frameworks differ: check6_frameworks_diff.txt"
  fi
else
  print_result "Binaries" "FAIL" ".app not found in DerivedData"
fi

# CHECK 7: Tests
if [ "$SKIP_TESTS" = false ]; then
  echo "--- CHECK 7: Tests ---"
  if xcodebuild test -workspace "$TUIST_WS" -scheme "$MODULE_TESTS_SCHEME" \
    -destination "platform=iOS Simulator,name=$DESTINATION" \
    2>&1 | tee "$OUT/check7_tests.txt" | tail -20; then
    print_result "Tests" "PASS" "Full suite passed"
  else
    print_result "Tests" "FAIL" "See check7_tests.txt"
  fi
else
  print_result "Tests" "WARN" "Skipped (--skip-tests)"
fi

# Final report
END=$(date +%s)
ELAPSED=$((END - START))
echo ""
echo "=== FINAL REPORT (${ELAPSED}s) ==="
echo "PASS: $PASS | WARN: $WARN | FAIL: $FAIL"
if [ "$FAIL" -eq 0 ]; then
  printf "${GREEN}MIGRATION VALID${NC}\n"
  echo "VERDICT: MIGRATION VALID" >> "$REPORT"
  exit 0
else
  printf "${RED}MIGRATION INVALID — $FAIL check(s) failed${NC}\n"
  echo "VERDICT: MIGRATION INVALID ($FAIL FAIL)" >> "$REPORT"
  exit 1
fi
