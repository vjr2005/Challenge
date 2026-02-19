import ProjectDescription

public enum NetworkingModule {
	public static let module = FrameworkModule.create(
		name: "Networking",
		testDependencies: [
			CoreModule.mocksTargetDependency
		],
		settings: .settings(base: [
			"SWIFT_DEFAULT_ACTOR_ISOLATION": .string("nonisolated"),
		])
	)

	public static let targetReferences: [TargetReference] = [
		.target("\(appName)Networking"),
	]
}
