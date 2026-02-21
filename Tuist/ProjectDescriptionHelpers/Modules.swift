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

	/// Test targets from all modules (added to root project).
	static var testTargets: [Target] {
		all.flatMap(\.targets)
	}

	/// Per-module test schemes.
	static var testSchemes: [Scheme] {
		all.flatMap(\.schemes)
	}

	/// All testable targets across all modules.
	static var testableTargets: [TestableTarget] {
		all.flatMap(\.testableTargets)
	}
}
