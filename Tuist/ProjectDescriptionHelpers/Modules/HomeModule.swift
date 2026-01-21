import ProjectDescription

public enum HomeModule {
	public static let module = FrameworkModule.create(
		name: "Home",
		path: "Features/Home",
		dependencies: [
			.target(name: "\(appName)Core"),
			.target(name: "\(appName)Character"),
			.target(name: "\(appName)Common"),
		],
		testDependencies: [
			.target(name: "\(appName)CoreMocks"),
			.external(name: "SnapshotTesting"),
		]
	)

	public static let targetReferences: [TargetReference] = [
		.target("\(appName)Home"),
	]
}
