import ProjectDescription

public enum DesignSystemModule {
	public static let module = FrameworkModule.create(
		name: "DesignSystem",
		testDependencies: [
			.external(name: "SnapshotTesting"),
		],
		hasMocks: false
	)

	public static let targetReferences: [TargetReference] = [
		.target("\(appName)DesignSystem"),
	]
}
