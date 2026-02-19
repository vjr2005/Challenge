import ProjectDescription

public enum AppKitModule {
	private static let name = "AppKit"

	public static let module = FrameworkModule.create(
		name: name,
		baseFolder: ".",
		path: "AppKit",
		dependencies: [
			CoreModule.targetDependency,
			HomeModule.targetDependency,
			CharacterModule.targetDependency,
			EpisodeModule.targetDependency,
			SystemModule.targetDependency,
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
