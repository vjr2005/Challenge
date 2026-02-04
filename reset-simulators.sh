#!/bin/zsh

echo "Killing Simulator processes..."
killall Simulator 2>/dev/null
killall com.apple.CoreSimulator.CoreSimulatorService 2>/dev/null

echo "Shutting down all simulators..."
xcrun simctl shutdown all

echo "Erasing all simulator data..."
xcrun simctl erase all

echo "Removing CoreSimulator caches..."
rm -rf ~/Library/Caches/com.apple.CoreSimulator

echo "Removing CoreSimulator logs..."
rm -rf ~/Library/Logs/CoreSimulator

echo "Restarting CoreSimulator service..."
launchctl remove com.apple.CoreSimulator.CoreSimulatorService 2>/dev/null

echo "Done. Simulators have been fully reset."
