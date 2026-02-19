import ProjectDescription

public let networkingModule = Module.create(
	directory: "Libraries/Networking",
	testDependencies: [
		coreModule.mocksTargetDependency,
	],
	targetSettingsOverrides: [
		"SWIFT_DEFAULT_ACTOR_ISOLATION": .string("nonisolated"),
	]
)
