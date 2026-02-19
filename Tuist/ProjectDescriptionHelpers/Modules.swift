import ProjectDescription

/// Central registry of all framework modules in the project.
/// Add new modules here to include them in the project.
public enum Modules {
	/// Path to the main app project (workspace root).
	public static let appProjectPath: ProjectDescription.Path = .path(workspaceRoot)

	/// Target reference for the main app target (workspace-level).
	public static var appTargetReference: TargetReference {
		.project(path: appProjectPath, target: appName)
	}

	/// All source target references for code coverage (workspace-level).
	public static var codeCoverageTargets: [TargetReference] {
		[
			appTargetReference,
			AppKitModule.targetReference,
			CoreModule.targetReference,
			NetworkingModule.targetReference,
			DesignSystemModule.targetReference,
			CharacterModule.targetReference,
			EpisodeModule.targetReference,
			HomeModule.targetReference,
			SystemModule.targetReference,
		]
	}

	/// App dependencies (modules that the app target depends on).
	public static var appDependencies: [TargetDependency] {
		[AppKitModule.targetDependency]
	}
}
