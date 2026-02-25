/// Selects the module integration strategy for the entire project.
///
/// Tuist 4.x does not support mixing SPM local packages and framework targets
/// in the same build. All modules must use the same strategy.
///
/// To switch strategy, change this typealias:
/// - `FrameworkModule`: Modules as framework targets in the root project.
/// - `SPMModule`: Modules as SPM local packages (each with its own `Package.swift`).
public typealias Module = FrameworkModule
