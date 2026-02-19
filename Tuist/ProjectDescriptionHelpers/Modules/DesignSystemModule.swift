import ProjectDescription

public enum DesignSystemModule {
	public static let module = FrameworkModule.create(
		name: "DesignSystem",
		dependencies: [
			CoreModule.targetDependency
		],
		testDependencies: [
			CoreModule.mocksTargetDependency
		],
		snapshotTestDependencies: [
			CoreModule.mocksTargetDependency
		]
	)

	public static let targetReferences: [TargetReference] = [
		.target("\(appName)DesignSystem"),
	]
}
