public let episodeModule = Module(
	directory: "Features/Episode",
	dependencies: [
		.module(coreModule),
		.module(designSystemModule),
		.module(networkingModule),
		.module(resourcesModule),
	],
	testDependencies: [
		.moduleMocks(coreModule),
		.moduleMocks(networkingModule),
	],
	snapshotTestDependencies: [
		.module(snapshotTestKitModule),
		.moduleMocks(coreModule),
		.moduleMocks(networkingModule),
	]
)
