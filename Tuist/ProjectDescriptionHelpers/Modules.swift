import ProjectDescription

/// Central registry of all modules in the project.
/// Add new modules here to include them in the workspace.
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

	/// All module project paths for the workspace.
	public static var projectPaths: [ProjectDescription.Path] {
		all.map(\.path)
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
