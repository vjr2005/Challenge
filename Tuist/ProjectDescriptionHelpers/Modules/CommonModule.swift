import ProjectDescription

public enum CommonModule {
	public static let module = FrameworkModule.create(
		name: "Common",
		dependencies: [
			.target(name: "\(appName)Core"),
		]
	)

	public static let targetReferences: [TargetReference] = [
		.target("\(appName)Common"),
	]
}
