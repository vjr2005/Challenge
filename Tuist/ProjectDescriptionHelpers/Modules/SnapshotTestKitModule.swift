import ProjectDescription

public let snapshotTestKitModule: any ModuleContract = FrameworkModule(
	directory: "Libraries/SnapshotTestKit",
	dependencies: [
		.external(snapshotTestingPackage),
	],
	includeInCoverage: false,
	settingsOverrides: [
		"ENABLE_TESTING_SEARCH_PATHS": "YES",
	]
)
