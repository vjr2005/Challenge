import ProjectDescription

public let characterModule = Module.create(
	directory: "Features/Character",
	dependencies: [
		coreModule.targetDependency,
		networkingModule.targetDependency,
		resourcesModule.targetDependency,
		designSystemModule.targetDependency,
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
