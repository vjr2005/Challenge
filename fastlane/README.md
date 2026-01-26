fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios install

```sh
[bundle exec] fastlane ios install
```

Install SPM dependencies

### ios generate

```sh
[bundle exec] fastlane ios generate
```

Generate Xcode project

### ios lint

```sh
[bundle exec] fastlane ios lint
```

Run SwiftLint

### ios detect_dead_code

```sh
[bundle exec] fastlane ios detect_dead_code
```

Run Periphery dead code detection

### ios execute_tests

```sh
[bundle exec] fastlane ios execute_tests
```

Execute unit tests

### ios clean

```sh
[bundle exec] fastlane ios clean
```

Clean Tuist cache and generated project

### ios ci

```sh
[bundle exec] fastlane ios ci
```

Full ci check (install + generate + execute_tests + detect_dead_code)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
