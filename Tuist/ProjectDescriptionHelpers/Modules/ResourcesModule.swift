import ProjectDescription

public let resourcesModule = Module.create(
	directory: "Shared/Resources",
	dependencies: [
		coreModule.targetDependency,
	],
	includeInCoverage: false
)
