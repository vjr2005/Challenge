import ProjectDescription

public enum AppKitModule {
	private static let name = "AppKit"

	public static let module = FrameworkModule.create(
		name: name,
		baseFolder: ".",
		path: "AppKit",
		dependencies: [
			.target(name: "\(appName)Core"),
			.target(name: "\(appName)Home"),
			.target(name: "\(appName)Character"),
			.target(name: "\(appName)Episode"),
			.target(name: "\(appName)System"),
			.target(name: "\(appName)Networking"),
		],
		testDependencies: [
			.target(name: "\(appName)CoreMocks"),
			.target(name: "\(appName)NetworkingMocks"),
		],
		snapshotTestDependencies: [
			.target(name: "\(appName)CoreMocks"),
			.target(name: "\(appName)NetworkingMocks"),
		]
	)

	public static var targetReferences: [TargetReference] {
		[.target("\(appName)\(name)")]
	}
}
