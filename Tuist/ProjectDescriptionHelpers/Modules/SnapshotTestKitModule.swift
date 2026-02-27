import ProjectDescription

public let snapshotTestKitModule = ModuleFactory.create(
	directory: "Libraries/SnapshotTestKit",
	dependencies: [
		.external(snapshotTestingPackage),
	],
	includeInCoverage: false,
	settingsOverrides: [
		"ENABLE_TESTING_SEARCH_PATHS": "YES",
	]
)
