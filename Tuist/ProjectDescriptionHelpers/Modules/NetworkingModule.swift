import ProjectDescription

public enum NetworkingModule {
	public static let module = FrameworkModule.create(
		name: "Networking",
		testDependencies: [
			.target(name: "\(appName)CoreMocks"),
		]
	)

	public static let targetReferences: [TargetReference] = [
		.target("\(appName)Networking"),
	]
}
