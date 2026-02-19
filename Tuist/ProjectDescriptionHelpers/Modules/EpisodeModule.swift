import ProjectDescription

public enum EpisodeModule {
	public static let module = FrameworkModule.create(
		name: "Episode",
		baseFolder: "Features",
		path: "Episode",
		dependencies: [
			CoreModule.targetDependency,
			DesignSystemModule.targetDependency,
			NetworkingModule.targetDependency,
			.target(name: "\(appName)Resources"),
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

	public static let targetReferences: [TargetReference] = [
		.target("\(appName)Episode"),
	]
}
