#!/bin/zsh

cd "$(dirname "$0")/.." || exit 1

APP_NAME=$(basename "$PWD")
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

# Expand focus to include transitive dependents using the Tuist project graph.
# If Character is focused, AppKit (which depends on Character) is also included.
# This ensures tests for all source-code modules are available in the Dev scheme.
if [[ -n "$FOCUS" ]]; then
    echo "Computing dependency graph..."
    GRAPH_DIR=$(mktemp -d)
    mise x -- tuist graph --format json --output-path "$GRAPH_DIR" 2>/dev/null
    GRAPH_FILE="$GRAPH_DIR/graph.json"

    # Build comma-separated target names for jq input
    FOCUSED_TARGETS=""
    for module in "${FOCUS_MODULES[@]}"; do
        if [[ -n "$FOCUSED_TARGETS" ]]; then
            FOCUSED_TARGETS="${FOCUSED_TARGETS},${APP_NAME}${module}"
        else
            FOCUSED_TARGETS="${APP_NAME}${module}"
        fi
    done

    # Compute transitive dependents from the graph:
    # 1. Parse dependency pairs into a forward map (module -> [dependencies])
    # 2. Filter to Challenge source modules (no Tests, Mocks, or app target)
    # 3. Starting from focused targets, iteratively find modules that depend on them
    EXPANDED_TARGETS=($(jq -r --arg focused "$FOCUSED_TARGETS" --arg app "$APP_NAME" '
      .dependencies as $deps |
      [range(0; $deps | length; 2)] |
      map({
        src: $deps[.].target.name,
        deps: [$deps[. + 1][] | .target.name? // empty]
      }) |
      map(select(
        (.src | startswith($app)) and
        (.src | test("Tests|Mocks") | not) and
        (.src == $app | not)
      )) |
      reduce .[] as $e ({}; . + {($e.src): $e.deps}) |
      . as $fwd |
      ($focused | split(",")) |
      {expanded: ., changed: true} |
      until(.changed == false;
        .changed = false |
        .expanded as $exp |
        reduce ($fwd | keys[]) as $mod (.;
          if ($exp | index($mod)) then .
          else
            if ($fwd[$mod] | any(. as $d | $exp | index($d))) then
              .expanded += [$mod] | .changed = true
            else . end
          end
        )
      ) |
      .expanded[]
    ' "$GRAPH_FILE"))
    rm -rf "$GRAPH_DIR"

    # Convert target names back to short names
    EXPANDED_MODULES=()
    for target in "${EXPANDED_TARGETS[@]}"; do
        EXPANDED_MODULES+=("${target#${APP_NAME}}")
    done

    # Report expansion
    DEPENDENTS=()
    for mod in "${EXPANDED_MODULES[@]}"; do
        if ! printf '%s\n' "${FOCUS_MODULES[@]}" | grep -qx "$mod"; then
            DEPENDENTS+=("$mod")
        fi
    done
    if [[ ${#DEPENDENTS[@]} -gt 0 ]]; then
        echo "Focus: ${FOCUS_MODULES[*]} (+ dependents: ${DEPENDENTS[*]})"
    fi
fi

export TUIST_MODULE_STRATEGY="$STRATEGY"

if [[ "$CLEAN" == true ]]; then
    echo "Cleaning Tuist cache..."
    mise x -- tuist clean plugins generatedAutomationProjects projectDescriptionHelpers manifests editProjects runs binaries selectiveTests dependencies

    echo "Removing generated project..."
    rm -rf *.xcodeproj *.xcworkspace

    echo "Removing Derived Data..."
    rm -rf ~/Library/Developer/Xcode/DerivedData/${APP_NAME}-*
fi

echo "Installing dependencies..."
mise x -- tuist install

# Focus mode: warm cache for non-focused dependencies
if [[ -n "$FOCUS" ]]; then
    echo "Warming cache for non-focused dependencies..."
    mise x -- tuist cache

    # Export expanded modules as target names for manifest filtering
    FOCUS_TARGET_NAMES=""
    for module in "${EXPANDED_MODULES[@]}"; do
        if [[ -n "$FOCUS_TARGET_NAMES" ]]; then
            FOCUS_TARGET_NAMES="${FOCUS_TARGET_NAMES},${APP_NAME}${module}"
        else
            FOCUS_TARGET_NAMES="${APP_NAME}${module}"
        fi
    done
    export TUIST_FOCUS_MODULES="$FOCUS_TARGET_NAMES"
fi

echo "Removing previous generated project..."
find . \( -path ./Tuist -o -path ./.git \) -prune -o -name "*.xcodeproj" -type d -print0 | xargs -0 rm -rf 2>/dev/null

if [[ -n "$FOCUS" ]]; then
    # Build tag queries for expanded modules (focused + dependents)
    TAG_QUERIES=()
    for module in "${EXPANDED_MODULES[@]}"; do
        TAG_QUERIES+=("tag:module:${module}")
    done

    echo "Generating project with focus on: $FOCUS (strategy: $STRATEGY)..."
    mise x -- tuist generate "$APP_NAME" "${APP_NAME}UITests" "${TAG_QUERIES[@]}" --cache-profile all-possible
else
    echo "Generating project (strategy: $STRATEGY)..."
    mise x -- tuist generate
fi
