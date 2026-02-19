import ProjectDescription

public let homeModule = Module.create(
	directory: "Features/Home",
	dependencies: [
		coreModule.targetDependency,
		designSystemModule.targetDependency,
		resourcesModule.targetDependency,
		.external(name: "Lottie"),
	],
	testDependencies: [
		coreModule.mocksTargetDependency,
	],
	snapshotTestDependencies: [
		coreModule.mocksTargetDependency,
	]
)
