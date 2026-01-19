import ProjectDescription

public enum CharacterModule {
	public static let module = FrameworkModule.create(
		name: "Character",
		path: "Features/Character",
		dependencies: [
			.target(name: "\(appName)Core"),
			.target(name: "\(appName)Networking"),
			.target(name: "\(appName)AppConfiguration"),
		],
		testDependencies: [
			.target(name: "\(appName)CoreMocks"),
			.target(name: "\(appName)NetworkingMocks"),
			.external(name: "SnapshotTesting"),
		],
		hasMocks: false
	)

	public static let targetReferences: [TargetReference] = [
		.target("\(appName)Character"),
	]
}
