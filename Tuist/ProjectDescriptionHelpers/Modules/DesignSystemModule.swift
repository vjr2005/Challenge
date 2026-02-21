import ProjectDescription

public let designSystemModule = Module.create(
	directory: "Libraries/DesignSystem",
	testDependencies: [
		coreModule.mocksTargetDependency,
	],
	snapshotTestDependencies: [
		coreModule.mocksTargetDependency,
	]
)
