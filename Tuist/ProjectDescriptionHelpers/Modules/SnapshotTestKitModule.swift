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
			sources: ["Libraries/SnapshotTestKit/Sources/**"],
			scripts: [SwiftLint.script(path: "Libraries/SnapshotTestKit/Sources")],
			dependencies: [
				.external(name: "SnapshotTesting"),
			],
			settings: .settings(base: [
				"ENABLE_TESTING_SEARCH_PATHS": "YES",
			])
		)

		let scheme = Scheme.scheme(
			name: targetName,
			buildAction: .buildAction(targets: [.target(targetName)])
		)

		return FrameworkModule(
			targets: [framework],
			schemes: [scheme]
		)
	}()
}
