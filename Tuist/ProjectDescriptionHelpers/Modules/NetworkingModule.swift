import ProjectDescription

public let networkingModule = ModuleFactory.create(
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
