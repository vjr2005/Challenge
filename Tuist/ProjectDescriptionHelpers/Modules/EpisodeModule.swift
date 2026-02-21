import ProjectDescription

public let episodeModule = Module.create(
	directory: "Features/Episode",
	testDependencies: [
		coreModule.mocksTargetDependency,
		networkingModule.mocksTargetDependency,
	],
	snapshotTestDependencies: [
		coreModule.mocksTargetDependency,
		networkingModule.mocksTargetDependency,
	]
)
