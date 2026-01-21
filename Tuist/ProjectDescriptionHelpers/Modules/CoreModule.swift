import ProjectDescription

public enum CoreModule {
	public static let module = FrameworkModule.create(name: "Core")

	public static let targetReferences: [TargetReference] = [
		.target("\(appName)Core"),
	]
}
