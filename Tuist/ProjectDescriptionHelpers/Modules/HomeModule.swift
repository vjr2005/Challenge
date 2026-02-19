import ProjectDescription

public enum HomeModule {
	public static let module = FrameworkModule.create(
		name: name,
		baseFolder: "Features",
		standalone: true,
		dependencies: [
			CoreModule.targetDependency,
			DesignSystemModule.targetDependency,
			ResourcesModule.targetDependency,
			.external(name: "Lottie"),
		],
		testDependencies: [
			CoreModule.mocksTargetDependency
		],
		snapshotTestDependencies: [
			CoreModule.mocksTargetDependency
		]
	)

	public static var project: Project {
		ProjectModule.create(module: module)
	}

	public static let path: ProjectDescription.Path = .path("\(workspaceRoot)/\(module.baseFolder)/\(name)")

	public static var targetDependency: TargetDependency {
		.project(target: module.name, path: path)
	}
}

private extension HomeModule {
	static let name = "Home"
}
