#!/bin/zsh

cd "$(dirname "$0")/.." || exit 1

DEFAULT_STRATEGY="framework"

usage() {
    echo "Usage: ./Scripts/generate.sh [--clean] [--strategy <spm|framework>]"
    echo ""
    echo "Generate the Xcode project."
    echo ""
    echo "Options:"
    echo "  --clean                Clean Tuist cache and reinstall dependencies before generating"
    echo "  --strategy <strategy>  Module integration strategy (default: $DEFAULT_STRATEGY)"
    exit 1
}

CLEAN=false
STRATEGY="$DEFAULT_STRATEGY"

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

echo "Removing previous generated project..."
find . \( -path ./Tuist -o -path ./.git \) -prune -o -name "*.xcodeproj" -type d -print0 | xargs -0 rm -rf 2>/dev/null

echo "Generating project (strategy: $STRATEGY)..."
mise x -- tuist generate
