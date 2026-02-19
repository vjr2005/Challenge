import ProjectDescription

public let episodeModule = Module.create(
	directory: "Features/Episode",
	dependencies: [
		coreModule.targetDependency,
		designSystemModule.targetDependency,
		networkingModule.targetDependency,
		resourcesModule.targetDependency,
	],
	testDependencies: [
		coreModule.mocksTargetDependency,
		networkingModule.mocksTargetDependency,
	],
	snapshotTestDependencies: [
		coreModule.mocksTargetDependency,
		networkingModule.mocksTargetDependency,
	]
)
