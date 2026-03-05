#!/bin/zsh

cd "$(dirname "$0")/.." || exit 1

# run-tests.sh
# Runs unit, snapshot, and UI tests with merged coverage results.
#
# Usage:
#   ./Scripts/run-tests.sh              # Sequential (unit+snapshot, then UI)
#   ./Scripts/run-tests.sh --parallel   # Parallel (clones simulator)
#   ./Scripts/run-tests.sh --unit       # Unit + Snapshot only
#   ./Scripts/run-tests.sh --ui         # UI tests only

WORKSPACE="Challenge.xcworkspace"
DEVICE="iPhone 17 Pro"
OS="26.1"
OUTPUT_DIR="test_output"
UNIT_XCRESULT="$OUTPUT_DIR/UnitSnapshot.xcresult"
UI_XCRESULT="$OUTPUT_DIR/UITests.xcresult"

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

source "$(dirname "$0")/test-helpers.sh"

trap cleanup_simulator EXIT

if $PARALLEL && $RUN_UNIT && $RUN_UI; then
    setup_parallel_simulator "$DEVICE" "$OS"
fi

clean "Challenge"
mkdir -p "$OUTPUT_DIR"

UNIT_EXIT=0
UI_EXIT=0
START_TIME=$(date +%s)

if $PARALLEL && $RUN_UNIT && $RUN_UI; then
    echo "Running tests in PARALLEL..."
    echo ""

    (
        run_tests "unit_snapshot" "$WORKSPACE" "Challenge (Dev)" \
            -resultBundlePath "$UNIT_XCRESULT" \
            -retry-tests-on-failure
    ) > "$OUTPUT_DIR/unit_snapshot_full.log" 2>&1 &
    PID_UNIT=$!

    (
        DESTINATION="$UI_DESTINATION"
        run_tests "ui" "$WORKSPACE" "ChallengeUITests" \
            -resultBundlePath "$UI_XCRESULT" \
            -retry-tests-on-failure \
            -test-repetition-relaunch-enabled YES
    ) > "$OUTPUT_DIR/ui_tests_full.log" 2>&1 &
    PID_UI=$!

    echo "  Unit + Snapshot tests (PID: $PID_UNIT)"
    echo "  UI tests              (PID: $PID_UI)"
    echo ""
    echo "Logs: $OUTPUT_DIR/unit_snapshot_full.log, $OUTPUT_DIR/ui_tests_full.log"
    echo "Waiting for both to finish..."
    echo ""

    wait $PID_UNIT || UNIT_EXIT=$?
    wait $PID_UI || UI_EXIT=$?
else
    # Sequential mode
    if $RUN_UNIT; then
        run_tests "unit_snapshot" "$WORKSPACE" "Challenge (Dev)" \
            -resultBundlePath "$UNIT_XCRESULT" \
            -retry-tests-on-failure
        UNIT_EXIT=$?
    fi

    if $RUN_UI; then
        DESTINATION="$UI_DESTINATION"
        run_tests "ui" "$WORKSPACE" "ChallengeUITests" \
            -resultBundlePath "$UI_XCRESULT" \
            -retry-tests-on-failure \
            -test-repetition-relaunch-enabled YES
        UI_EXIT=$?
    fi
fi

END_TIME=$(date +%s)
TOTAL_TIME=$((END_TIME - START_TIME))

# Merge xcresult bundles if both suites ran
RESULT_PATH=""
if $RUN_UNIT && $RUN_UI && [[ -d "$UNIT_XCRESULT" ]] && [[ -d "$UI_XCRESULT" ]]; then
    merge_xcresults "$UNIT_XCRESULT" "$UI_XCRESULT"
    if [[ -n "$MERGED_XCRESULT_PATH" ]]; then
        RESULT_PATH="$MERGED_XCRESULT_PATH"
    else
        RESULT_PATH="$UNIT_XCRESULT"
    fi
elif $RUN_UNIT && [[ -d "$UNIT_XCRESULT" ]]; then
    RESULT_PATH="$UNIT_XCRESULT"
elif $RUN_UI && [[ -d "$UI_XCRESULT" ]]; then
    RESULT_PATH="$UI_XCRESULT"
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
