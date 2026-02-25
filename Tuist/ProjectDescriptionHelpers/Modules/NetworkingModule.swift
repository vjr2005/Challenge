import ProjectDescription

public let networkingModule: any ModuleContract = FrameworkModule(
	directory: "Libraries/Networking",
	dependencies: [
		.module(coreModule),
	],
	testDependencies: [
		.moduleMocks(coreModule),
	],
	settingsOverrides: [
		"SWIFT_DEFAULT_ACTOR_ISOLATION": .string("nonisolated"),
	]
)
