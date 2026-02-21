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

	/// All package references for Project.swift packages array.
	static var packageReferences: [Package] {
		all.map(\.packageReference)
	}
}
