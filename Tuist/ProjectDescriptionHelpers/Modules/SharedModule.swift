import ProjectDescription

public enum SharedModule {
	public static let module = FrameworkModule.create(
		name: "Shared",
		baseFolder: "Shared",
		path: "Common",
		dependencies: [
			.target(name: "\(appName)Core"),
		]
	)

	public static let targetReferences: [TargetReference] = [
		.target("\(appName)Shared"),
	]
}
