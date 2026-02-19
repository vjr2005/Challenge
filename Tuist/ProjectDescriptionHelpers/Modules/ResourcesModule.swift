import ProjectDescription

public enum ResourcesModule {
	public static let module = FrameworkModule.create(
		name: name,
		baseFolder: "Shared",
		path: name,
		standalone: true,
		dependencies: [
			CoreModule.targetDependency
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

private extension ResourcesModule {
	static let name = "Resources"
}
