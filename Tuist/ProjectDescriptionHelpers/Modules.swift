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

	/// All module targets (root project aggregates these).
	static var frameworkTargets: [Target] {
		all.flatMap(\.targets)
	}

	/// All module schemes (root project includes these).
	static var frameworkSchemes: [Scheme] {
		all.flatMap(\.schemes)
	}

	/// All testable targets across all modules.
	static var testableTargets: [TestableTarget] {
		all.flatMap(\.testableTargets)
	}

	/// All source target references for code coverage (modules only, excludes app).
	static var codeCoverageTargets: [TargetReference] {
		all.filter(\.includeInCoverage).map { .target($0.name) }
	}
}
