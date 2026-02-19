import ProjectDescription

/// Creates a standalone Tuist `Project` from a `FrameworkModule`.
public enum ProjectModule {
	/// Wraps a framework module in a project with standard settings.
	/// - Parameter module: The framework module containing targets and schemes.
	public static func create(module: FrameworkModule) -> Project {
		Project(
			name: module.name,
			options: .options(
				automaticSchemesOptions: .disabled,
				disableBundleAccessors: true,
				disableSynthesizedResourceAccessors: true
			),
			settings: .settings(
				base: [
					"SWIFT_VERSION": .string(swiftVersion),
					"SWIFT_APPROACHABLE_CONCURRENCY": .string("YES"),
					"SWIFT_DEFAULT_ACTOR_ISOLATION": .string("MainActor"),
					"ENABLE_USER_SCRIPT_SANDBOXING": .string("NO"),
				],
				configurations: BuildConfiguration.all
			),
			targets: module.targets,
			schemes: module.schemes
		)
	}
}
