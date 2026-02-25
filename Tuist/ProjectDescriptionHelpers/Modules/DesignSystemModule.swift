public let designSystemModule = Module(
	directory: "Libraries/DesignSystem",
	dependencies: [
		.module(coreModule),
	],
	testDependencies: [
		.moduleMocks(coreModule),
	],
	snapshotTestDependencies: [
		.module(snapshotTestKitModule),
		.moduleMocks(coreModule),
	]
)
