import ProjectDescription

public let snapshotTestKitModule = Module.create(
	directory: "Libraries/SnapshotTestKit",
	dependencies: [
		.external(name: "SnapshotTesting"),
	],
	includeInCoverage: false,
	targetSettingsOverrides: [
		"ENABLE_TESTING_SEARCH_PATHS": "YES",
	]
)
