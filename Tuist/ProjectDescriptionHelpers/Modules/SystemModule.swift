import ProjectDescription

public let systemModule = Module.create(
	directory: "Features/System",
	testDependencies: [
		coreModule.mocksTargetDependency,
	],
	snapshotTestDependencies: [
		coreModule.mocksTargetDependency,
	]
)
