import ProjectDescription

public enum SnapshotTestKitModule {
	public static let module: FrameworkModule = {
		let targetName = "\(appName)SnapshotTestKit"

		let framework = Target.target(
			name: targetName,
			destinations: destinations,
			product: .framework,
			bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}.\(targetName)",
			deploymentTargets: developmentTarget,
			sources: ["Sources/**"],
			scripts: [SwiftLint.script(path: "Sources", workspaceRoot: "../..")],
			dependencies: [
				.external(name: "SnapshotTesting"),
			],
			settings: .settings(base: projectBaseSettings.merging([
				"ENABLE_TESTING_SEARCH_PATHS": "YES",
			]) { _, new in new })
		)

		let scheme = Scheme.scheme(
			name: targetName,
			buildAction: .buildAction(targets: [.target(targetName)])
		)

		return FrameworkModule(
			baseFolder: "Libraries",
			name: targetName,
			targets: [framework],
			schemes: [scheme]
		)
	}()

	public static var project: Project {
		ProjectModule.create(module: module)
	}

	public static let path: ProjectDescription.Path = .path("\(workspaceRoot)/\(module.baseFolder)/\(name)")

	public static var targetDependency: TargetDependency {
		.project(target: module.name, path: path)
	}
}

private extension SnapshotTestKitModule {
	static let name = "SnapshotTestKit"
}
