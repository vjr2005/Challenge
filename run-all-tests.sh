#!/bin/zsh

# run-all-tests.sh
# Runs unit, snapshot, and UI tests with merged coverage results.
#
# Usage:
#   ./run-all-tests.sh              # Sequential (unit+snapshot, then UI)
#   ./run-all-tests.sh --parallel   # Parallel (clones simulator)
#   ./run-all-tests.sh --unit       # Unit + Snapshot only
#   ./run-all-tests.sh --ui         # UI tests only

WORKSPACE="Challenge.xcworkspace"
DEVICE="iPhone 17 Pro"
OS="26.1"
OUTPUT_DIR="test_output"

usage() {
    sed -n '/^# Usage/,/^$/p' "$0" | sed 's/^# //'
    exit 1
}

PARALLEL=false
RUN_UNIT=true
RUN_UI=true

while [[ $# -gt 0 ]]; do
    case "$1" in
        --parallel) PARALLEL=true; shift ;;
        --unit)     RUN_UI=false; shift ;;
        --ui)       RUN_UNIT=false; shift ;;
        --help|-h)  usage ;;
        *)          usage ;;
    esac
done

DESTINATION="platform=iOS Simulator,name=$DEVICE,OS=$OS"
UI_DESTINATION="$DESTINATION"
CREATED_SIMULATOR=false

cleanup() {
    # Only delete the simulator if we created it in this run
    if $CREATED_SIMULATOR && [[ -n "$CLONE_UDID" ]]; then
        echo "Cleaning up test simulator..."
        xcrun simctl delete "$CLONE_UDID" 2>/dev/null || true
    fi
}
trap cleanup EXIT

# For parallel mode, find or create a second simulator so both
# xcodebuild processes don't fight over the same device
CLONE_UDID=""
if $PARALLEL && $RUN_UNIT && $RUN_UI; then
    CLONE_NAME="${DEVICE} (Tests Clone)"
    DEVICE_ID="com.apple.CoreSimulator.SimDeviceType.${DEVICE// /-}"
    RUNTIME_ID="com.apple.CoreSimulator.SimRuntime.iOS-${OS//./-}"

    # Find existing simulator, preferring booted over shutdown
    CLONE_LINE=$(xcrun simctl list devices "iOS $OS" | grep "$CLONE_NAME" | grep "Booted" | head -1)
    if [[ -z "$CLONE_LINE" ]]; then
        CLONE_LINE=$(xcrun simctl list devices "iOS $OS" | grep "$CLONE_NAME" | head -1)
    fi

    if [[ -n "$CLONE_LINE" ]]; then
        CLONE_UDID=$(echo "$CLONE_LINE" | grep -oE '[0-9A-Fa-f]{8}-([0-9A-Fa-f]{4}-){3}[0-9A-Fa-f]{12}')
        echo "Reusing existing simulator: $CLONE_NAME ($CLONE_UDID)"
    else
        echo "Creating simulator for parallel execution..."
        CLONE_UDID=$(xcrun simctl create "$CLONE_NAME" "$DEVICE_ID" "$RUNTIME_ID")
        CREATED_SIMULATOR=true
        echo "Created simulator: $CLONE_NAME ($CLONE_UDID)"
    fi

    # Always ensure English locale (boot → configure → shutdown)
    # xcodebuild will boot it again with the correct language applied
    xcrun simctl boot "$CLONE_UDID" 2>/dev/null || true
    xcrun simctl spawn "$CLONE_UDID" defaults write "Apple Global Domain" AppleLanguages -array en
    xcrun simctl spawn "$CLONE_UDID" defaults write "Apple Global Domain" AppleLocale -string en_US
    xcrun simctl shutdown "$CLONE_UDID" 2>/dev/null || true

    UI_DESTINATION="platform=iOS Simulator,id=$CLONE_UDID"
fi

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

UNIT_EXIT=0
UI_EXIT=0
START_TIME=$(date +%s)

if $PARALLEL && $RUN_UNIT && $RUN_UI; then
    echo "Running tests in PARALLEL..."
    echo ""

    # Each xcodebuild needs its own DerivedData to avoid "database is locked" errors
    UNIT_DERIVED_DATA="$OUTPUT_DIR/derived_data_unit"
    UI_DERIVED_DATA="$OUTPUT_DIR/derived_data_ui"

    # Redirect to files to avoid interleaved output
    xcodebuild test \
        -workspace "$WORKSPACE" \
        -scheme "Challenge (Dev)" \
        -testPlan Challenge \
        -destination "$DESTINATION" \
        -derivedDataPath "$UNIT_DERIVED_DATA" \
        -resultBundlePath "$OUTPUT_DIR/UnitSnapshot.xcresult" \
        -enableCodeCoverage YES \
        -retry-tests-on-failure \
        > "$OUTPUT_DIR/unit_snapshot.log" 2>&1 &
    PID_UNIT=$!

    xcodebuild test \
        -workspace "$WORKSPACE" \
        -scheme "ChallengeUITests" \
        -destination "$UI_DESTINATION" \
        -derivedDataPath "$UI_DERIVED_DATA" \
        -resultBundlePath "$OUTPUT_DIR/UITests.xcresult" \
        -enableCodeCoverage YES \
        -retry-tests-on-failure \
        -test-repetition-relaunch-enabled YES \
        > "$OUTPUT_DIR/ui_tests.log" 2>&1 &
    PID_UI=$!

    echo "  Unit + Snapshot tests (PID: $PID_UNIT)"
    echo "  UI tests              (PID: $PID_UI)"
    echo ""
    echo "Logs: $OUTPUT_DIR/unit_snapshot.log, $OUTPUT_DIR/ui_tests.log"
    echo "Waiting for both to finish..."
    echo ""

    wait $PID_UNIT || UNIT_EXIT=$?
    wait $PID_UI || UI_EXIT=$?
else
    # Sequential mode
    if $RUN_UNIT; then
        echo "Running unit + snapshot tests..."
        xcodebuild test \
            -workspace "$WORKSPACE" \
            -scheme "Challenge (Dev)" \
            -testPlan Challenge \
            -destination "$DESTINATION" \
            -resultBundlePath "$OUTPUT_DIR/UnitSnapshot.xcresult" \
            -enableCodeCoverage YES \
            -retry-tests-on-failure \
            2>&1 | tee "$OUTPUT_DIR/unit_snapshot.log"
        UNIT_EXIT=${pipestatus[1]}
    fi

    if $RUN_UI; then
        echo "Running UI tests..."
        xcodebuild test \
            -workspace "$WORKSPACE" \
            -scheme "ChallengeUITests" \
            -destination "$UI_DESTINATION" \
            -resultBundlePath "$OUTPUT_DIR/UITests.xcresult" \
            -enableCodeCoverage YES \
            -retry-tests-on-failure \
            -test-repetition-relaunch-enabled YES \
            2>&1 | tee "$OUTPUT_DIR/ui_tests.log"
        UI_EXIT=${pipestatus[1]}
    fi
fi

END_TIME=$(date +%s)
TOTAL_TIME=$((END_TIME - START_TIME))

# Merge xcresult bundles if both suites ran
# Replicate CI structure: inputs in separate dirs, output in its own dir
RESULT_PATH=""
if $RUN_UNIT && $RUN_UI; then
    echo "Merging xcresult bundles..."
    MERGE_DIR="$OUTPUT_DIR/merged"
    mkdir -p "$MERGE_DIR"
    if xcrun xcresulttool merge \
        "$OUTPUT_DIR/UnitSnapshot.xcresult" \
        "$OUTPUT_DIR/UITests.xcresult" \
        --output-path "$MERGE_DIR/AllTests.xcresult"; then
        RESULT_PATH="$MERGE_DIR/AllTests.xcresult"
    else
        echo "Warning: merge failed. Opening UnitSnapshot.xcresult instead."
        RESULT_PATH="$OUTPUT_DIR/UnitSnapshot.xcresult"
    fi
elif $RUN_UNIT; then
    RESULT_PATH="$OUTPUT_DIR/UnitSnapshot.xcresult"
elif $RUN_UI; then
    RESULT_PATH="$OUTPUT_DIR/UITests.xcresult"
fi

# Summary
echo ""
echo "=============================="
echo "  Test Results"
echo "=============================="
if $RUN_UNIT; then
    echo "  Unit + Snapshot: $([ $UNIT_EXIT -eq 0 ] && echo 'PASSED' || echo 'FAILED')"
fi
if $RUN_UI; then
    echo "  UI Tests:        $([ $UI_EXIT -eq 0 ] && echo 'PASSED' || echo 'FAILED')"
fi
echo "  Total time:      ${TOTAL_TIME}s"
if [[ -n "$RESULT_PATH" ]]; then
    echo "  Result:          $RESULT_PATH"
fi
echo "=============================="

# Open result in Xcode
if [[ -n "$RESULT_PATH" ]] && [[ -d "$RESULT_PATH" ]]; then
    open "$RESULT_PATH"
fi

# Exit with failure if any suite failed
[[ $UNIT_EXIT -eq 0 ]] && [[ $UI_EXIT -eq 0 ]]
