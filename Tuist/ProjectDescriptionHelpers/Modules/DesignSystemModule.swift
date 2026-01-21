import ProjectDescription

public enum DesignSystemModule {
	public static let module = FrameworkModule.create(
		name: "DesignSystem",
		dependencies: [
			.target(name: "\(appName)Core"),
		],
		testDependencies: [
			.target(name: "\(appName)CoreMocks"),
			.external(name: "SnapshotTesting"),
		]
	)

	public static let targetReferences: [TargetReference] = [
		.target("\(appName)DesignSystem"),
	]
}
