import ProjectDescription

/// Central registry of all framework modules in the project.
/// Add new modules here to include them in the project.
public enum Modules {
	/// All framework modules in dependency order.
	private static let all: [FrameworkModule] = [
		ResourcesModule.module,
		CharacterModule.module,
		EpisodeModule.module,
		HomeModule.module,
		SystemModule.module,
		AppKitModule.module,
	]

	/// All targets from all modules.
	public static var targets: [Target] {
		all.flatMap(\.targets)
	}

	/// All schemes from all modules.
	public static var schemes: [Scheme] {
		all.flatMap(\.schemes)
	}

	/// All target references for code coverage.
	/// Includes only source targets (app and framework sources).
	/// Never include mock targets - they exist to support tests, not to be measured.
	public static var codeCoverageTargets: [TargetReference] {
		[.target(appName)]
			+ ResourcesModule.targetReferences
			+ CharacterModule.targetReferences
			+ EpisodeModule.targetReferences
			+ HomeModule.targetReferences
			+ SystemModule.targetReferences
			+ AppKitModule.targetReferences
	}

	/// App dependencies (modules that the app target depends on).
	public static var appDependencies: [TargetDependency] {
		[
			.target(name: "\(appName)AppKit"),
		]
	}
}
