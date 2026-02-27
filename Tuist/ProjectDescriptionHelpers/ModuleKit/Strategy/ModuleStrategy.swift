import ProjectDescription

/// Available module integration strategies.
///
/// Tuist 4.x does not support mixing SPM local packages and framework targets
/// in the same build. All modules must use the same strategy.
///
/// - `.spm`: Modules as SPM local packages (each with its own `Package.swift`).
/// - `.framework`: Modules as framework targets in the root project.
public enum ModuleStrategy: String {
	case spm
	case framework

	/// The active strategy for the entire project.
	///
	/// Resolved from the `TUIST_MODULE_STRATEGY` environment variable at generation time.
	/// Falls back to `.spm` when the variable is not set.
	///
	/// Usage:
	/// ```bash
	/// TUIST_MODULE_STRATEGY=framework ./generate.sh
	/// ```
	public static let active: ModuleStrategy = {
		if case let .string(value) = ProjectDescription.Environment.moduleStrategy {
			return ModuleStrategy(rawValue: value) ?? .spm
		}
		return .spm
	}()
}
