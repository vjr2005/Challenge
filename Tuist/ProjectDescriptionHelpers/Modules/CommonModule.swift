import ProjectDescription

public enum CommonModule {
	public static let module = FrameworkModule.create(
		name: "Common"
	)

	public static let targetReferences: [TargetReference] = [
		.target("\(appName)Common"),
	]
}
