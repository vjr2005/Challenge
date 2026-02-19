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
				base: projectBaseSettings,
				configurations: BuildConfiguration.all
			),
			targets: module.targets,
			schemes: module.schemes
		)
	}
}
