import ProjectDescription

public enum NetworkingModule {
	public static let module = FrameworkModule.create(
		name: name,
		standalone: true,
		testDependencies: [
			CoreModule.mocksTargetDependency
		],
		targetSettingsOverrides: [
			"SWIFT_DEFAULT_ACTOR_ISOLATION": .string("nonisolated"),
		]
	)

	public static var project: Project {
		ProjectModule.create(module: module)
	}

	public static let path: ProjectDescription.Path = .path("\(workspaceRoot)/\(module.baseFolder)/\(name)")

	public static var testableTargets: [TestableTarget] {
		[
			.testableTarget(target: .project(path: path, target: "\(module.name)Tests"), parallelization: .swiftTestingOnly),
		]
	}

	public static var targetReference: TargetReference {
		.project(path: path, target: module.name)
	}

	public static var targetDependency: TargetDependency {
		.project(target: module.name, path: path)
	}

	public static var mocksTargetDependency: TargetDependency {
		.project(target: module.name.appending("Mocks"), path: path)
	}
}

private extension NetworkingModule {
	static let name = "Networking"
}
