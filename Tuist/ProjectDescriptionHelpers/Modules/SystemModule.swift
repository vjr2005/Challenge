import ProjectDescription

public let systemModule = Module.create(
	directory: "Features/System",
	dependencies: [
		coreModule.targetDependency,
		resourcesModule.targetDependency,
		designSystemModule.targetDependency,
	],
	testDependencies: [
		coreModule.mocksTargetDependency,
	],
	snapshotTestDependencies: [
		coreModule.mocksTargetDependency,
	]
)
