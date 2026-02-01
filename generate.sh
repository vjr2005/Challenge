#!/bin/zsh

usage() {
    echo "Usage: ./generate.sh [--clean]"
    echo ""
    echo "Generate the Xcode project."
    echo ""
    echo "Options:"
    echo "  --clean  Clean Tuist cache and reinstall dependencies before generating"
    exit 1
}

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    usage
fi

if [[ $# -gt 1 || ( $# -eq 1 && "$1" != "--clean" ) ]]; then
    usage
fi

if [[ "$1" == "--clean" ]]; then
    echo "Cleaning Tuist cache..."
    mise x -- tuist clean plugins generatedAutomationProjects projectDescriptionHelpers manifests editProjects runs binaries selectiveTests dependencies

    echo "Removing generated project..."
    rm -rf *.xcodeproj *.xcworkspace

    echo "Removing Derived Data..."
    rm -rf ~/Library/Developer/Xcode/DerivedData/Challenge-*
fi

echo "Installing dependencies..."
mise x -- tuist install

echo "Generating project..."
mise x -- tuist generate
