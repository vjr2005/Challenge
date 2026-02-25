public let characterModule: any ModuleContract = FrameworkModule(
	directory: "Features/Character",
	dependencies: [
		.module(coreModule),
		.module(networkingModule),
		.module(resourcesModule),
		.module(designSystemModule),
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
