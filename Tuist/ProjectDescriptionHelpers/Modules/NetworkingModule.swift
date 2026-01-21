import ProjectDescription

public enum NetworkingModule {
	public static let module = FrameworkModule.create(name: "Networking")

	public static let targetReferences: [TargetReference] = [
		.target("\(appName)Networking"),
	]
}
