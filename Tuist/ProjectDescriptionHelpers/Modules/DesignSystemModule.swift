public let designSystemModule: any ModuleContract = FrameworkModule(
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
