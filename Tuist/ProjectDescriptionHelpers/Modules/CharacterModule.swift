import ProjectDescription

public enum CharacterModule {
	public static let module = FrameworkModule.create(
		name: "Character",
		baseFolder: "Features",
		path: "Character",
		dependencies: [
			CoreModule.targetDependency,
			NetworkingModule.targetDependency,
			ResourcesModule.targetDependency,
			DesignSystemModule.targetDependency,
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
		.target("\(appName)Character"),
	]
}
