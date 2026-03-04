# Scripts

All scripts live in the `Scripts/` directory. Each script uses `cd "$(dirname "$0")/.."` to resolve paths relative to the project root, so they can be invoked from any directory.

## Available Scripts

| Script | Description |
|--------|-------------|
| `./Scripts/setup.sh` | Initial setup - installs brew, mise, and project tools |
| `./Scripts/generate.sh` | Install dependencies and generate the Xcode project (framework strategy) |
| `./Scripts/generate.sh --clean` | Clean Tuist cache, then install dependencies and generate |
| `./Scripts/generate.sh --strategy spm` | Generate using the SPM module strategy |
| `./Scripts/reset-simulators.sh` | Full simulator reset - fixes corrupted simulator state |
| `./Scripts/run-tests.sh` | Run unit, snapshot, and UI tests with merged xcresult |
| `./Scripts/run-tests.sh --parallel` | Same as above, but runs both suites in parallel (clones simulator) |
| `./Scripts/run-tests.sh --unit` | Run unit + snapshot tests only |
| `./Scripts/run-tests.sh --ui` | Run UI tests only |
| `Scripts/BuildPhases/run-swiftlint.sh` | Runs SwiftLint on the codebase (Xcode build phase) |

### Directory Structure

```
Scripts/
├── setup.sh              # Initial setup
├── generate.sh           # Project generation
├── reset-simulators.sh   # Simulator reset
├── run-tests.sh          # Test runner (project-specific)
├── test-helpers.sh       # Generic test helper functions (shared with CI)
├── BuildPhases/
│   └── run-swiftlint.sh  # Xcode build phase
└── CI/
    ├── test-results-summary.py  # Test failure/retry markdown report
    ├── coverage-report.js       # Coverage table + threshold check
    └── periphery-summary.js     # Periphery dead code markdown report
```

`test-helpers.sh` is compatible with both bash (CI) and zsh (local). CI workflows source it and call `run_tests` with `-resultBundlePath` for predictable artifact paths. See [CI](CI.md) for details.

## Setup Script

Run the setup script to install all required tools:

```bash
./Scripts/setup.sh
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
./Scripts/generate.sh
```

### Module Strategy

Switch the module integration strategy at generation time:

```bash
./Scripts/generate.sh --strategy framework   # Framework targets (default)
./Scripts/generate.sh --strategy spm         # SPM local packages
```

Options can be combined:

```bash
./Scripts/generate.sh --clean --strategy framework
```

### Clean Build

To perform a clean build from scratch:

```bash
./Scripts/generate.sh --clean
```

This clears the Tuist cache before generating, useful when:
- Switching branches with different dependencies
- Switching module strategies
- Resolving cached state issues
- Starting fresh after major changes

## Reset Simulators Script

Performs a deep reset of all iOS simulators. Use this script when you suspect the simulator has corrupted data (e.g., `LaunchServicesDataMismatch` errors, apps crashing immediately after launch, UI tests timing out unexpectedly):

```bash
./Scripts/reset-simulators.sh
```

This script will:
- Kill all running Simulator and CoreSimulator processes
- Shut down and erase all simulator devices
- Remove CoreSimulator caches (`~/Library/Caches/com.apple.CoreSimulator`)
- Remove CoreSimulator logs (`~/Library/Logs/CoreSimulator`)
- Restart the CoreSimulator service to regenerate the LaunchServices database

> **Important:** After running this script, **restart Xcode** before launching the app or running tests. Xcode holds a connection to the CoreSimulator service that becomes invalid after the reset.

## Run Tests Script

Run all test suites (unit, snapshot, and UI) with a merged xcresult:

```bash
./Scripts/run-tests.sh
```

The script is split into two files:
- `run-tests.sh` — project-specific orchestration (workspace, schemes, test plans)
- `test-helpers.sh` — generic reusable functions (`run_tests`, `find_xcresult`, `merge_xcresults`, `clean`)

xcresult bundles stay in DerivedData (via `-derivedDataPath`) so that Xcode build log references (`x-xcode-log://`) resolve correctly when opened in Report Navigator.

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

The `Scripts/BuildPhases/run-swiftlint.sh` script is executed as an Xcode build phase. It:
- Runs SwiftLint on all Swift files
- Reports warnings and errors in Xcode
- Is configured via `.swiftlint.yml`

## CI Scripts

The `Scripts/CI/` directory contains report generation scripts used by GitHub Actions workflows. Each script reads input from environment variables and writes output to stdout, making them testable locally.

| Script | Language | Description |
|--------|----------|-------------|
| `test-results-summary.py` | Python | Parses `.xcresult` for test failures and retries, generates markdown summary |
| `coverage-report.js` | Node.js | Merges coverage data, generates coverage table, checks threshold |
| `periphery-summary.js` | Node.js | Parses Periphery output, generates markdown table of unused code |

Workflows capture stdout and handle GitHub-specific plumbing (`GITHUB_STEP_SUMMARY`, `GITHUB_OUTPUT`, PR comments) separately. See [CI](CI.md) for details.
