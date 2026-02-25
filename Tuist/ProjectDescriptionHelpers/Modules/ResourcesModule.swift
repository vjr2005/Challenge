public let resourcesModule: any ModuleContract = FrameworkModule(
	directory: "Shared/Resources",
	dependencies: [
		.module(coreModule),
	],
	includeInCoverage: false
)
