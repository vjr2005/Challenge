import ProjectDescription

public let designSystemModule = Module.create(
	directory: "Libraries/DesignSystem",
	dependencies: [
		coreModule.targetDependency,
	],
	testDependencies: [
		coreModule.mocksTargetDependency,
	],
	snapshotTestDependencies: [
		coreModule.mocksTargetDependency,
	]
)
