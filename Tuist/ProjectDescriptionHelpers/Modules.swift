import ProjectDescription

/// Central registry of all modules in the project.
public enum Modules {
	/// All modules in the project.
	static let all: [Module] = [
		coreModule,
		networkingModule,
		snapshotTestKitModule,
		designSystemModule,
		resourcesModule,
		characterModule,
		episodeModule,
		homeModule,
		systemModule,
		appKitModule,
	]

	/// Project paths for standalone-project-mode modules (Workspace includes these).
	public static var standaloneProjectPaths: [ProjectDescription.Path] {
		all.filter { $0.strategy == .project }.map(\.path)
	}

	/// Targets from framework-mode modules (root project aggregates these).
	static var frameworkTargets: [Target] {
		all.filter { $0.strategy == .framework }.flatMap(\.targets)
	}

	/// Schemes from framework-mode modules (root project includes these).
	static var frameworkSchemes: [Scheme] {
		all.filter { $0.strategy == .framework }.flatMap(\.schemes)
	}

	/// All testable targets across all modules.
	static var testableTargets: [TestableTarget] {
		all.flatMap(\.testableTargets)
	}

	/// All source target references for code coverage (modules only, excludes app).
	static var codeCoverageTargets: [TargetReference] {
		all.filter(\.includeInCoverage).map(\.targetReference)
	}
}
