import ProjectDescription

public let appKitModule = Module.create(
	directory: "AppKit",
	testDependencies: [
		coreModule.mocksTargetDependency,
		networkingModule.mocksTargetDependency,
	],
	snapshotTestDependencies: [
		coreModule.mocksTargetDependency,
		networkingModule.mocksTargetDependency,
	]
)
