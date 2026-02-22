#!/bin/zsh
# generate.sh — Generates the Xcode project with Tuist

if [[ "$1" == "--clean" ]]; then
    echo "Cleaning Tuist cache..."
    mise x -- tuist clean
    rm -rf *.xcodeproj *.xcworkspace
    rm -rf ~/Library/Developer/Xcode/DerivedData/NombreApp-*  # ← Adjust app name
fi

echo "Installing dependencies..."
mise x -- tuist install

echo "Removing previous projects..."
find . -path ./Tuist -prune -o -name "*.xcodeproj" -print -exec rm -rf {} + 2>/dev/null

echo "Generating project..."
mise x -- tuist generate
