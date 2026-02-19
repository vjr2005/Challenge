import ProjectDescription

public enum EpisodeModule {
	public static let module = FrameworkModule.create(
		name: name,
		baseFolder: "Features",
		standalone: true,
		dependencies: [
			CoreModule.targetDependency,
			DesignSystemModule.targetDependency,
			NetworkingModule.targetDependency,
			ResourcesModule.targetDependency,
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

	public static var testableTargets: [TestableTarget] {
		[
			.testableTarget(target: .project(path: path, target: "\(module.name)Tests"), parallelization: .swiftTestingOnly),
			.testableTarget(target: .project(path: path, target: "\(module.name)SnapshotTests"), parallelization: .swiftTestingOnly),
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

private extension EpisodeModule {
	static let name = "Episode"
}
