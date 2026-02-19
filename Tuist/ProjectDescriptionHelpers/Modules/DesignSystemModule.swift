import ProjectDescription

public enum DesignSystemModule {
	public static let module = FrameworkModule.create(
		name: name,
		standalone: true,
		dependencies: [
			CoreModule.targetDependency
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
}

private extension DesignSystemModule {
	static let name = "DesignSystem"
}
