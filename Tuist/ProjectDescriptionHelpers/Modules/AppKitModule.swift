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
			NetworkingModule.targetDependency,
		],
		testDependencies: [
			CoreModule.mocksTargetDependency,
			NetworkingModule.mocksTargetDependency,
		],
		snapshotTestDependencies: [
			CoreModule.mocksTargetDependency,
			NetworkingModule.mocksTargetDependency,
		]
	)

	public static var targetReferences: [TargetReference] {
		[.target("\(appName)\(name)")]
	}
}
