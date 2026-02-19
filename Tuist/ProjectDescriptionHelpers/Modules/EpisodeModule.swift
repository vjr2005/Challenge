import ProjectDescription

public enum EpisodeModule {
	public static let module = FrameworkModule.create(
		name: "Episode",
		baseFolder: "Features",
		path: "Episode",
		dependencies: [
			CoreModule.targetDependency,
			.target(name: "\(appName)DesignSystem"),
			.target(name: "\(appName)Networking"),
			.target(name: "\(appName)Resources"),
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

	public static let targetReferences: [TargetReference] = [
		.target("\(appName)Episode"),
	]
}
