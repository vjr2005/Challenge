import ProjectDescription

/// Unified aggregation logic for module collections.
///
/// Dispatches on ``ModuleStrategy/active`` to produce the test action:
/// - **Framework**: Uses `.targets(...)` with aggregated testable targets and
///   code coverage targets — no file generation side-effect.
/// - **SPM**: Generates a `.xctestplan` via ``TestPlanGenerator`` and uses
///   `.testPlans(...)`, which is the only mechanism to aggregate test targets
///   across SPM local packages.
///
/// **Focus mode:** When `TUIST_FOCUS_MODULES` is set, only the specified modules'
/// test targets and coverage targets are included in the Dev scheme test action.
enum ModuleAggregation {
	/// Module names to focus on, read from `TUIST_FOCUS_MODULES` env var.
	///
	/// Comma-separated target names (e.g., `"ChallengeCharacter,ChallengeEpisode"`).
	/// When empty, all modules are included (normal mode).
	static let focusModuleNames: Set<String> = {
		guard case let .string(value) = ProjectDescription.Environment.focusModules else {
			return []
		}
		return Set(value.split(separator: ",").map(String.init))
	}()

	/// Whether focus mode is active.
	static var isFocused: Bool { !focusModuleNames.isEmpty }

	/// Generates a test action for the aggregate Dev scheme.
	///
	/// - Framework: Collects `testableTargets` and `codeCoverageTargets` from
	///   each module and returns `.targets(...)`.
	/// - SPM: Generates a test plan via `TestPlanGenerator` and returns
	///   `.testPlans(...)`. The test plan is the default in the scheme, so
	///   `xcodebuild test -scheme "Challenge (Dev)"` picks it up automatically.
	///
	/// When `TUIST_FOCUS_MODULES` is set, only focused modules contribute
	/// testable and coverage targets.
	static func aggregateTestAction(
		modules: [any ModuleContract],
		appTargetReference: TargetReference,
		config: ProjectConfig = projectConfig
	) -> TestAction {
		let effectiveModules = filteredModules(from: modules)

		switch ModuleStrategy.active {
		case .framework:
			let allTestableTargets = effectiveModules.flatMap(\.testableTargets)
			let allCoverageTargets = [appTargetReference] + effectiveModules.flatMap(\.codeCoverageTargets)
			return .targets(
				allTestableTargets,
				options: .options(
					coverage: true,
					codeCoverageTargets: allCoverageTargets
				)
			)
		case .spm:
			let testPlanName = TestPlanGenerator.generate(
				appName: config.appName,
				modules: effectiveModules
			)
			return .testPlans([Path(stringLiteral: testPlanName)])
		}
	}

	/// Filters modules to only focused ones when focus mode is active.
	///
	/// Returns all modules when `TUIST_FOCUS_MODULES` is not set.
	static func filteredModules(from modules: [any ModuleContract]) -> [any ModuleContract] {
		guard isFocused else { return modules }
		return modules.filter { focusModuleNames.contains($0.name) }
	}
}
