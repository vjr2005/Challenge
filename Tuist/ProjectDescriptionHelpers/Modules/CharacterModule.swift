import ProjectDescription

public enum CharacterModule {
	public static let module = FrameworkModule.create(
		name: "Character",
		path: "Features/Character",
		dependencies: [
			.target(name: "\(appName)Core"),
			.target(name: "\(appName)Networking"),
			.target(name: "\(appName)Common"),
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
