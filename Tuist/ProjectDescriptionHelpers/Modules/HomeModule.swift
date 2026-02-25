public let homeModule: any ModuleContract = FrameworkModule(
	directory: "Features/Home",
	dependencies: [
		.module(coreModule),
		.module(designSystemModule),
		.module(resourcesModule),
		.external(lottiePackage),
	],
	testDependencies: [
		.moduleMocks(coreModule),
	],
	snapshotTestDependencies: [
		.module(snapshotTestKitModule),
		.moduleMocks(coreModule),
	]
)
