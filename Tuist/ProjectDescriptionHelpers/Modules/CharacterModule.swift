import ProjectDescription

public enum CharacterModule {
	public static let module = FrameworkModule.create(
		name: "Character",
		baseFolder: "Features",
		path: "Character",
		dependencies: [
			.target(name: "\(appName)Core"),
			.target(name: "\(appName)Networking"),
			.target(name: "\(appName)Shared"),
			.target(name: "\(appName)DesignSystem"),
		],
		testDependencies: [
			.target(name: "\(appName)CoreMocks"),
			.target(name: "\(appName)NetworkingMocks"),
			.external(name: "SnapshotTesting"),
		]
	)

	public static let targetReferences: [TargetReference] = [
		.target("\(appName)Character"),
	]
}
