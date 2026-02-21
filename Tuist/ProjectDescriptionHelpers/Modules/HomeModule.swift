import ProjectDescription

public let homeModule = Module.create(
	directory: "Features/Home",
	testDependencies: [
		coreModule.mocksTargetDependency,
	],
	snapshotTestDependencies: [
		coreModule.mocksTargetDependency,
	]
)
