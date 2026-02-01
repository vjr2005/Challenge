# Scripts

## Available Scripts

| Script | Description |
|--------|-------------|
| `./setup.sh` | Initial setup - installs brew, mise, and project tools |
| `./generate.sh` | Install dependencies and generate the Xcode project |
| `./generate.sh --clean` | Clean Tuist cache, then install dependencies and generate |
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

## SwiftLint Script

The `Scripts/run_swiftlint.sh` script is executed as an Xcode build phase. It:
- Runs SwiftLint on all Swift files
- Reports warnings and errors in Xcode
- Is configured via `.swiftlint.yml`
