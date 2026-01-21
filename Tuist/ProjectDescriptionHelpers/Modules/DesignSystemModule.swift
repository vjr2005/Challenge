import ProjectDescription

public enum DesignSystemModule {
	public static let module = FrameworkModule.create(
		name: "DesignSystem",
		testDependencies: [
			.external(name: "SnapshotTesting"),
		]
	)

	public static let targetReferences: [TargetReference] = [
		.target("\(appName)DesignSystem"),
	]
}
