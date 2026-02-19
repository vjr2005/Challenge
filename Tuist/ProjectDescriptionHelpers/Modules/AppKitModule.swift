import ProjectDescription

public enum AppKitModule {
	public static let module = FrameworkModule.create(
		name: name,
		baseFolder: ".",
		path: name,
		standalone: true,
		dependencies: [
			CoreModule.targetDependency,
			HomeModule.targetDependency,
			CharacterModule.targetDependency,
			EpisodeModule.targetDependency,
			SystemModule.targetDependency,
			NetworkingModule.targetDependency,
		],
		testDependencies: [
			CoreModule.mocksTargetDependency,
			NetworkingModule.mocksTargetDependency,
		],
		snapshotTestDependencies: [
			CoreModule.mocksTargetDependency,
			NetworkingModule.mocksTargetDependency,
		]
	)

	public static var project: Project {
		ProjectModule.create(module: module)
	}

	public static let path: ProjectDescription.Path = .path("\(workspaceRoot)/\(name)")

	public static var targetDependency: TargetDependency {
		.project(target: module.name, path: path)
	}
}

private extension AppKitModule {
	static let name = "AppKit"
}
