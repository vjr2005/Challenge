import ProjectDescription

/// Creates modules using the active ``ModuleStrategy``.
public enum ModuleFactory {
	/// Creates a module using the active strategy.
	public static func create(
		directory: String,
		dependencies: [ModuleDependency] = [],
		testDependencies: [ModuleDependency] = [],
		snapshotTestDependencies: [ModuleDependency] = [],
		includeInCoverage: Bool = true,
		settingsOverrides: SettingsDictionary = [:],
		config: ProjectConfig = projectConfig
	) -> any ModuleContract {
		switch ModuleStrategy.active {
		case .spm:
			SPMModule(
				directory: directory,
				dependencies: dependencies,
				testDependencies: testDependencies,
				snapshotTestDependencies: snapshotTestDependencies,
				includeInCoverage: includeInCoverage,
				settingsOverrides: settingsOverrides,
				config: config
			)
		case .framework:
			FrameworkModule(
				directory: directory,
				dependencies: dependencies,
				testDependencies: testDependencies,
				snapshotTestDependencies: snapshotTestDependencies,
				includeInCoverage: includeInCoverage,
				settingsOverrides: settingsOverrides,
				config: config
			)
		}
	}
}
