import ProjectDescription

public enum EpisodeModule {
	public static let module = FrameworkModule.create(
		name: "Episode",
		baseFolder: "Features",
		path: "Episode",
		dependencies: [
			.target(name: "\(appName)Core"),
			.target(name: "\(appName)DesignSystem"),
			.target(name: "\(appName)Resources"),
		],
		testDependencies: [
			.target(name: "\(appName)CoreMocks"),
		],
		snapshotTestDependencies: [
			.target(name: "\(appName)CoreMocks"),
		]
	)

	public static let targetReferences: [TargetReference] = [
		.target("\(appName)Episode"),
	]
}
