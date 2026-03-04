#!/bin/zsh

# Generic test helper functions.
# Compatible with both bash (CI) and zsh (local).
#
# Environment variables:
#   DESTINATION        — xcodebuild destination (required)
#   OUTPUT_DIR         — base directory for logs and results (required)
#   DERIVED_DATA_PATH  — override DerivedData path (optional, defaults to $OUTPUT_DIR/<name>_derived_data)

# Runs tests and sets XCRESULT_PATH to the -resultBundlePath value.
# Returns the xcodebuild exit code.
# Usage: run_tests <name> <workspace> <scheme> [extra xcodebuild flags...]
run_tests() {
    local name="$1"
    local workspace="$2"
    local scheme="$3"
    shift 3
    local derived_data="${DERIVED_DATA_PATH:-$OUTPUT_DIR/${name}_derived_data}"

    # Detect -resultBundlePath in extra args
    local result_bundle_path=""
    local args=("$@")
    for ((i=0; i<${#args[@]}; i++)); do
        if [[ "${args[$i]}" == "-resultBundlePath" ]]; then
            result_bundle_path="${args[$((i+1))]}"
            break
        fi
    done

    mkdir -p "$OUTPUT_DIR"

    echo "Running tests for scheme '$scheme'..."
    xcodebuild test \
        -workspace "$workspace" \
        -scheme "$scheme" \
        -destination "$DESTINATION" \
        -derivedDataPath "$derived_data" \
        -enableCodeCoverage YES \
        "$@" \
        2>&1 | tee "$OUTPUT_DIR/${name}.log" | tail -5
    local test_exit
    if [[ -n "${BASH_VERSION:-}" ]]; then
        test_exit=${PIPESTATUS[0]}
    else
        test_exit=${pipestatus[1]}
    fi

    XCRESULT_PATH="$result_bundle_path"

    return $test_exit
}

# Merges two xcresult bundles.
# Usage: merge_xcresults <xcresult_a> <xcresult_b>
# Sets MERGED_XCRESULT_PATH to the result.
merge_xcresults() {
    local xcresult_a="$1"
    local xcresult_b="$2"
    MERGED_XCRESULT_PATH="$OUTPUT_DIR/merged/AllTests.xcresult"

    mkdir -p "$OUTPUT_DIR/merged"

    echo "Merging xcresult bundles..."
    if ! xcrun xcresulttool merge "$xcresult_a" "$xcresult_b" \
        --output-path "$MERGED_XCRESULT_PATH"; then
        echo "Warning: merge failed"
        MERGED_XCRESULT_PATH=""
    fi
}

# Cleans previous output and default DerivedData to prevent stale coverage artifacts.
# Usage: clean <project_name>
clean() {
    local project_name="$1"
    rm -rf "$OUTPUT_DIR" 2>/dev/null
    if [[ -d "$OUTPUT_DIR" ]]; then
        echo "Warning: could not fully remove $OUTPUT_DIR (Xcode may have it open). Retrying..."
        sleep 1
        rm -rf "$OUTPUT_DIR" 2>/dev/null
    fi
    echo "Cleaning default DerivedData..."
    find ~/Library/Developer/Xcode/DerivedData -maxdepth 1 -name "${project_name}-*" -exec rm -rf {} + 2>/dev/null
}

# Creates or reuses a cloned simulator for parallel test execution.
# Usage: setup_parallel_simulator <device> <os>
# Sets: CLONE_UDID, CREATED_SIMULATOR, UI_DESTINATION
CLONE_UDID=""
CREATED_SIMULATOR=false

setup_parallel_simulator() {
    local device="$1"
    local os="$2"
    local clone_name="${device} (Tests Clone)"
    local device_id="com.apple.CoreSimulator.SimDeviceType.${device// /-}"
    local runtime_id="com.apple.CoreSimulator.SimRuntime.iOS-${os//./-}"

    # Find existing simulator, preferring booted over shutdown
    local clone_line
    clone_line=$(xcrun simctl list devices "iOS $os" | grep "$clone_name" | grep "Booted" | head -1)
    if [[ -z "$clone_line" ]]; then
        clone_line=$(xcrun simctl list devices "iOS $os" | grep "$clone_name" | head -1)
    fi

    if [[ -n "$clone_line" ]]; then
        CLONE_UDID=$(echo "$clone_line" | grep -oE '[0-9A-Fa-f]{8}-([0-9A-Fa-f]{4}-){3}[0-9A-Fa-f]{12}')
        echo "Reusing existing simulator: $clone_name ($CLONE_UDID)"
    else
        echo "Creating simulator for parallel execution..."
        CLONE_UDID=$(xcrun simctl create "$clone_name" "$device_id" "$runtime_id")
        CREATED_SIMULATOR=true
        echo "Created simulator: $clone_name ($CLONE_UDID)"
    fi

    # Ensure English locale (boot → configure → shutdown)
    # xcodebuild will boot it again with the correct language applied
    xcrun simctl boot "$CLONE_UDID" 2>/dev/null || true
    xcrun simctl spawn "$CLONE_UDID" defaults write "Apple Global Domain" AppleLanguages -array en
    xcrun simctl spawn "$CLONE_UDID" defaults write "Apple Global Domain" AppleLocale -string en_US
    xcrun simctl shutdown "$CLONE_UDID" 2>/dev/null || true

    UI_DESTINATION="platform=iOS Simulator,id=$CLONE_UDID"
}

# Cleans up a cloned simulator created by setup_parallel_simulator.
# Use with: trap cleanup_simulator EXIT
cleanup_simulator() {
    if $CREATED_SIMULATOR && [[ -n "$CLONE_UDID" ]]; then
        echo "Cleaning up test simulator..."
        xcrun simctl delete "$CLONE_UDID" 2>/dev/null || true
    fi
}
