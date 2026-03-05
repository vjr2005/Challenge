#!/bin/zsh

cd "$(dirname "$0")/.." || exit 1

DEFAULT_STRATEGY="framework"
MODULES_DIR="Tuist/ProjectDescriptionHelpers/Modules"
VALID_MODULES=($(ls "$MODULES_DIR"/*Module.swift 2>/dev/null | sed 's|.*/||;s|Module\.swift||'))

usage() {
    echo "Usage: ./Scripts/generate.sh [--clean] [--strategy <spm|framework>] [--focus <module1,module2,...>]"
    echo ""
    echo "Generate the Xcode project."
    echo ""
    echo "Options:"
    echo "  --clean                Clean Tuist cache and reinstall dependencies before generating"
    echo "  --strategy <strategy>  Module integration strategy (default: $DEFAULT_STRATEGY)"
    echo "  --focus <modules>      Focus on specific modules (comma-separated short names)."
    echo "                         Focused modules stay as source code with tests."
    echo "                         Everything else is substituted with cached XCFrameworks."
    echo "                         Only available with framework strategy."
    echo ""
    echo "Available modules for --focus:"
    echo "  ${VALID_MODULES[*]}"
    echo ""
    echo "Examples:"
    echo "  ./Scripts/generate.sh"
    echo "  ./Scripts/generate.sh --focus Character"
    echo "  ./Scripts/generate.sh --focus Character,Episode"
    echo "  ./Scripts/generate.sh --clean --focus Character"
    exit 1
}

CLEAN=false
STRATEGY="$DEFAULT_STRATEGY"
FOCUS=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --clean)
            CLEAN=true
            shift
            ;;
        --strategy)
            if [[ -z "$2" || "$2" == --* ]]; then
                echo "Error: --strategy requires a value (spm or framework)"
                exit 1
            fi
            STRATEGY="$2"
            shift 2
            ;;
        --focus)
            if [[ -z "$2" || "$2" == --* ]]; then
                echo "Error: --focus requires a comma-separated list of module names"
                exit 1
            fi
            FOCUS="$2"
            shift 2
            ;;
        --help|-h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

if [[ "$STRATEGY" != "spm" && "$STRATEGY" != "framework" ]]; then
    echo "Error: Invalid strategy '$STRATEGY'. Valid values: spm, framework"
    exit 1
fi

if [[ -n "$FOCUS" && "$STRATEGY" == "spm" ]]; then
    echo "Error: --focus requires framework strategy (tuist cache does not support SPM targets)"
    exit 1
fi

# Validate focus modules
if [[ -n "$FOCUS" ]]; then
    IFS=',' read -rA FOCUS_MODULES <<< "$FOCUS"
    for module in "${FOCUS_MODULES[@]}"; do
        if ! printf '%s\n' "${VALID_MODULES[@]}" | grep -qx "$module"; then
            echo "Error: Unknown module '$module'"
            echo "Valid modules: ${VALID_MODULES[*]}"
            exit 1
        fi
    done
fi

export TUIST_MODULE_STRATEGY="$STRATEGY"

if [[ "$CLEAN" == true ]]; then
    echo "Cleaning Tuist cache..."
    mise x -- tuist clean plugins generatedAutomationProjects projectDescriptionHelpers manifests editProjects runs binaries selectiveTests dependencies

    echo "Removing generated project..."
    rm -rf *.xcodeproj *.xcworkspace

    echo "Removing Derived Data..."
    PROJECT_NAME=$(basename "$PWD")
    rm -rf ~/Library/Developer/Xcode/DerivedData/${PROJECT_NAME}-*
fi

echo "Installing dependencies..."
mise x -- tuist install

# Focus mode: warm cache and remove focused modules
if [[ -n "$FOCUS" ]]; then
    CACHE_DIR="$HOME/.cache/tuist/Binaries"

    echo "Computing module hashes..."
    HASH_OUTPUT=$(mise x -- tuist hash cache 2>&1 | grep -E " - [a-f0-9]{32}$")

    # Check cache warmth
    TOTAL_HASHES=$(echo "$HASH_OUTPUT" | wc -l | tr -d ' ')
    CACHED_COUNT=0
    while IFS= read -r line; do
        hash=$(echo "$line" | awk '{print $NF}')
        if [[ -d "$CACHE_DIR/$hash" ]]; then
            CACHED_COUNT=$((CACHED_COUNT + 1))
        fi
    done <<< "$HASH_OUTPUT"

    if [[ "$CACHED_COUNT" -lt "$TOTAL_HASHES" ]]; then
        echo "Warming cache ($CACHED_COUNT/$TOTAL_HASHES modules cached)..."
        mise x -- tuist cache
    else
        echo "Cache is warm ($CACHED_COUNT/$TOTAL_HASHES modules cached). Skipping cache step."
    fi

    # Remove focused modules from cache so they stay as source
    echo "Removing focused modules from cache..."
    for module in "${FOCUS_MODULES[@]}"; do
        TARGET_NAME="Challenge${module}"

        HASH=$(echo "$HASH_OUTPUT" | grep "^${TARGET_NAME} " | awk '{print $NF}')
        if [[ -n "$HASH" && -d "$CACHE_DIR/$HASH" ]]; then
            echo "  $TARGET_NAME -> source"
            rm -rf "$CACHE_DIR/$HASH"
        fi

        MOCKS_HASH=$(echo "$HASH_OUTPUT" | grep "^${TARGET_NAME}Mocks " | awk '{print $NF}')
        if [[ -n "$MOCKS_HASH" && -d "$CACHE_DIR/$MOCKS_HASH" ]]; then
            echo "  ${TARGET_NAME}Mocks -> source"
            rm -rf "$CACHE_DIR/$MOCKS_HASH"
        fi
    done
fi

echo "Removing previous generated project..."
find . \( -path ./Tuist -o -path ./.git \) -prune -o -name "*.xcodeproj" -type d -print0 | xargs -0 rm -rf 2>/dev/null

if [[ -n "$FOCUS" ]]; then
    echo "Generating project with focus on: $FOCUS (strategy: $STRATEGY)..."
    mise x -- tuist generate --cache-profile all-possible
else
    echo "Generating project (strategy: $STRATEGY)..."
    mise x -- tuist generate
fi
