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

	/// All testable targets across all modules.
	static var testableTargets: [TestableTarget] {
		all.flatMap(\.testableTargets)
	}

	/// All source target references for code coverage (modules only, excludes app).
	static var codeCoverageTargets: [TargetReference] {
		all.filter(\.includeInCoverage).map(\.codeCoverageTargetReference)
	}

	/// Paths to all module projects for workspace inclusion.
	public static var projectPaths: [Path] {
		all.map { .relativeToRoot($0.directory) }
	}
}
