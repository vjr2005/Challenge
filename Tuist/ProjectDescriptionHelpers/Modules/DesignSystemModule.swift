public let designSystemModule = ModuleFactory.create(
	directory: "Libraries/DesignSystem",
	dependencies: [
		.module(coreModule),
	],
	snapshotTestDependencies: [
		.module(snapshotTestKitModule),
		.moduleMocks(coreModule),
	]
)
