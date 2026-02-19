import ProjectDescription

public enum CoreModule {
	public static let module = FrameworkModule.create(name: name, standalone: true)

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

private extension CoreModule {
	static let name = "Core"
}
