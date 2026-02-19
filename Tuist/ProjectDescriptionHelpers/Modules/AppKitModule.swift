import ProjectDescription

public enum AppKitModule {
	private static let name = "AppKit"

	public static let module = FrameworkModule.create(
		name: name,
		baseFolder: ".",
		path: "AppKit",
		dependencies: [
			CoreModule.targetDependency,
			.target(name: "\(appName)Home"),
			.target(name: "\(appName)Character"),
			.target(name: "\(appName)Episode"),
			.target(name: "\(appName)System"),
			.target(name: "\(appName)Networking"),
		],
		testDependencies: [
			CoreModule.mocksTargetDependency,
			.target(name: "\(appName)NetworkingMocks"),
		],
		snapshotTestDependencies: [
			CoreModule.mocksTargetDependency,
			.target(name: "\(appName)NetworkingMocks"),
		]
	)

	public static var targetReferences: [TargetReference] {
		[.target("\(appName)\(name)")]
	}
}
