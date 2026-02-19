import ProjectDescription

public let appKitModule = Module.create(
	directory: "AppKit",
	dependencies: [
		coreModule.targetDependency,
		homeModule.targetDependency,
		characterModule.targetDependency,
		episodeModule.targetDependency,
		systemModule.targetDependency,
		networkingModule.targetDependency,
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
