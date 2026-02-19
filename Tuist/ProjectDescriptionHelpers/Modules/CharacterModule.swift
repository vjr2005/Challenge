import ProjectDescription

public enum CharacterModule {
	public static let module = FrameworkModule.create(
		name: "Character",
		baseFolder: "Features",
		path: "Character",
		dependencies: [
			CoreModule.targetDependency,
			.target(name: "\(appName)Networking"),
			.target(name: "\(appName)Resources"),
			.target(name: "\(appName)DesignSystem"),
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
		.target("\(appName)Character"),
	]
}
