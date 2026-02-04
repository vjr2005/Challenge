# Scripts

## Available Scripts

| Script | Description |
|--------|-------------|
| `./setup.sh` | Initial setup - installs brew, mise, and project tools |
| `./generate.sh` | Install dependencies and generate the Xcode project |
| `./generate.sh --clean` | Clean Tuist cache, then install dependencies and generate |
| `./reset-simulators.sh` | Full simulator reset - fixes corrupted simulator state |
| `Scripts/run_swiftlint.sh` | Runs SwiftLint on the codebase (Xcode build phase) |

## Setup Script

Run the setup script to install all required tools:

```bash
./setup.sh
```

This script will:
- Install **Homebrew** (if not installed)
- Install **mise** (tool version manager)
- Configure mise activation in your shell
- Install project tools from `.mise.toml`:
  - `tuist` - Project generation
  - `swiftlint` - Code linting
  - `periphery` - Dead code detection

## Generate Script

Generate the Xcode project and install dependencies:

```bash
./generate.sh
```

### Clean Build

To perform a clean build from scratch:

```bash
./generate.sh --clean
```

This clears the Tuist cache before generating, useful when:
- Switching branches with different dependencies
- Resolving cached state issues
- Starting fresh after major changes

## Reset Simulators Script

Performs a deep reset of all iOS simulators. Use this script when you suspect the simulator has corrupted data (e.g., `LaunchServicesDataMismatch` errors, apps crashing immediately after launch, UI tests timing out unexpectedly):

```bash
./reset-simulators.sh
```

This script will:
- Kill all running Simulator and CoreSimulator processes
- Shut down and erase all simulator devices
- Remove CoreSimulator caches (`~/Library/Caches/com.apple.CoreSimulator`)
- Remove CoreSimulator logs (`~/Library/Logs/CoreSimulator`)
- Restart the CoreSimulator service to regenerate the LaunchServices database

> **Important:** After running this script, **restart Xcode** before launching the app or running tests. Xcode holds a connection to the CoreSimulator service that becomes invalid after the reset.

## SwiftLint Script

The `Scripts/run_swiftlint.sh` script is executed as an Xcode build phase. It:
- Runs SwiftLint on all Swift files
- Reports warnings and errors in Xcode
- Is configured via `.swiftlint.yml`
