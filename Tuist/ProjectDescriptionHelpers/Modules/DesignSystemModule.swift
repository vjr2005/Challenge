import ProjectDescription

public enum DesignSystemModule {
	public static let module = FrameworkModule.create(
		name: "DesignSystem",
		dependencies: [
			.target(name: "\(appName)Core"),
		],
		testDependencies: [
			.target(name: "\(appName)CoreMocks"),
		],
		snapshotTestDependencies: [
			.target(name: "\(appName)CoreMocks"),
		]
	)

	public static let targetReferences: [TargetReference] = [
		.target("\(appName)DesignSystem"),
	]
}
