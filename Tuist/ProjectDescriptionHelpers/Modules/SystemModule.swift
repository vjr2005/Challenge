public let systemModule = ModuleFactory.create(
	directory: "Features/System",
	dependencies: [
		.module(coreModule),
		.module(resourcesModule),
		.module(designSystemModule),
	],
	testDependencies: [
		.moduleMocks(coreModule),
	],
	snapshotTestDependencies: [
		.module(snapshotTestKitModule),
		.moduleMocks(coreModule),
	]
)
