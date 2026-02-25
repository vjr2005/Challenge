public let resourcesModule = Module(
	directory: "Shared/Resources",
	dependencies: [
		.module(coreModule),
	],
	includeInCoverage: false
)
