public let resourcesModule = ModuleFactory.create(
	directory: "Shared/Resources",
	dependencies: [
		.module(coreModule),
	],
	includeInCoverage: false
)
