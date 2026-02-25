public let appKitModule: any ModuleContract = FrameworkModule(
	directory: "AppKit",
	dependencies: [
		.module(coreModule),
		.module(homeModule),
		.module(characterModule),
		.module(episodeModule),
		.module(systemModule),
		.module(networkingModule),
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
