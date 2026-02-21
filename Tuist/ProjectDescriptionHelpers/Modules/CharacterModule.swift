import ProjectDescription

public let characterModule = Module.create(
	directory: "Features/Character",
	testDependencies: [
		coreModule.mocksTargetDependency,
		networkingModule.mocksTargetDependency,
	],
	snapshotTestDependencies: [
		coreModule.mocksTargetDependency,
		networkingModule.mocksTargetDependency,
	]
)
