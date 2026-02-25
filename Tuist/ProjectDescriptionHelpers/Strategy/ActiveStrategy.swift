/// The active module integration strategy.
///
/// Change this typealias to switch between SPM local packages and framework targets.
/// After changing, run `./generate.sh` to regenerate the project. CI requires no changes.
///
/// Available implementations:
/// - `SPMModule`: Modules as SPM local packages (each with its own `Package.swift`).
/// - `FrameworkModule`: Modules as framework targets in the root project.
// public typealias Module = SPMModule
public typealias Module = FrameworkModule
