public let designSystemModule = ModuleFactory.create(
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
