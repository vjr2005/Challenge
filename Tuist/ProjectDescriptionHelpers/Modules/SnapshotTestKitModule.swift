import ProjectDescription

public let snapshotTestKitModule = Module.create(
	directory: "Libraries/SnapshotTestKit",
	dependencies: [
		.external(name: "SnapshotTesting"),
	],
	targetSettingsOverrides: [
		"ENABLE_TESTING_SEARCH_PATHS": "YES",
	]
)
