import ProjectDescription

public enum AppConfigurationModule {
	public static let module = FrameworkModule.create(
		name: "AppConfiguration",
		hasMocks: false
	)

	public static let targetReferences: [TargetReference] = [
		.target("\(appName)AppConfiguration"),
	]
}
