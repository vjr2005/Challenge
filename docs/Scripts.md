# Scripts

## Available Scripts

| Script | Description |
|--------|-------------|
| `./setup.sh` | Initial setup - installs brew, mise, and project tools |
| `./generate.sh` | Install dependencies and generate the Xcode project (framework strategy) |
| `./generate.sh --clean` | Clean Tuist cache, then install dependencies and generate |
| `./generate.sh --strategy spm` | Generate using the SPM module strategy |
| `./reset-simulators.sh` | Full simulator reset - fixes corrupted simulator state |
| `./run-all-tests.sh` | Run unit, snapshot, and UI tests with merged xcresult |
| `./run-all-tests.sh --parallel` | Same as above, but runs both suites in parallel (clones simulator) |
| `./run-all-tests.sh --unit` | Run unit + snapshot tests only |
| `./run-all-tests.sh --ui` | Run UI tests only |
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

### Module Strategy

Switch the module integration strategy at generation time:

```bash
./generate.sh --strategy framework   # Framework targets (default)
./generate.sh --strategy spm         # SPM local packages
```

Options can be combined:

```bash
./generate.sh --clean --strategy framework
```

### Clean Build

To perform a clean build from scratch:

```bash
./generate.sh --clean
```

This clears the Tuist cache before generating, useful when:
- Switching branches with different dependencies
- Switching module strategies
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

## Run All Tests Script

Run all test suites (unit, snapshot, and UI) with a merged xcresult:

```bash
./run-all-tests.sh
```

### Options

| Flag | Description |
|------|-------------|
| `--parallel` | Clone the simulator and run unit+snapshot and UI tests in parallel |
| `--unit` | Run only unit + snapshot tests |
| `--ui` | Run only UI tests |

### Sequential Mode (default)

Runs unit+snapshot tests first, then UI tests. Output streams to the terminal via `tee` and is also saved to log files in `test_output/`.

### Parallel Mode

Reuses an existing "iPhone 17 Pro (Tests Clone)" simulator if one exists with iOS 26.1; otherwise creates one with English locale and keeps it for future runs. Output is redirected to log files (use `tail -f test_output/unit_snapshot.log` to follow progress).

### Result Merging

When both suites run, the script merges the two `.xcresult` bundles into `test_output/merged/AllTests.xcresult` using `xcresulttool merge` (same tool the CI uses). The merged result is opened automatically in Xcode, showing unified test results and coverage.

## SwiftLint Script

The `Scripts/run_swiftlint.sh` script is executed as an Xcode build phase. It:
- Runs SwiftLint on all Swift files
- Reports warnings and errors in Xcode
- Is configured via `.swiftlint.yml`
