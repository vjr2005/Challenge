import ProjectDescription

public enum CharacterModule {
	public static let module = FrameworkModule.create(
		name: name,
		baseFolder: "Features",
		standalone: true,
		dependencies: [
			CoreModule.targetDependency,
			NetworkingModule.targetDependency,
			ResourcesModule.targetDependency,
			DesignSystemModule.targetDependency,
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

	public static let path: ProjectDescription.Path = .path("\(workspaceRoot)/\(module.baseFolder)/\(name)")

	public static var targetDependency: TargetDependency {
		.project(target: module.name, path: path)
	}

	public static var mocksTargetDependency: TargetDependency {
		.project(target: module.name.appending("Mocks"), path: path)
	}
}

private extension CharacterModule {
	static let name = "Character"
}
