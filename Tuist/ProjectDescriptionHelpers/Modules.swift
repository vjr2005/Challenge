import ProjectDescription

/// Central registry of all framework modules in the project.
/// Add new modules here to include them in the project.
public enum Modules {
	/// All target references for code coverage.
	/// Only includes the app target — standalone modules own their coverage.
	public static var codeCoverageTargets: [TargetReference] {
		[.target(appName)]
	}

	/// App dependencies (modules that the app target depends on).
	public static var appDependencies: [TargetDependency] {
		[AppKitModule.targetDependency]
	}
}
