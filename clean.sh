#!/bin/zsh

# 1. Clean Tuist cache
tuist clean plugins generatedAutomationProjects projectDescriptionHelpers manifests editProjects runs binaries selectiveTests dependencies

# 2. Remove generated project
rm -rf *.xcodeproj *.xcworkspace

# 3. Generate the project
tuist generate
