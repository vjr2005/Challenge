import ProjectDescription

public enum ResourcesModule {
	public static let module = FrameworkModule.create(
		name: "Resources",
		baseFolder: "Shared",
		path: "Resources",
		dependencies: [
			.target(name: "\(appName)Core"),
		]
	)

	public static let targetReferences: [TargetReference] = [
		.target("\(appName)Resources"),
	]
}
