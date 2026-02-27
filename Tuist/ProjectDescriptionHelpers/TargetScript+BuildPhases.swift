import ProjectDescription

extension TargetScript {
	/// SwiftLint post-build script.
	static func swiftLint(path: String) -> TargetScript {
		.post(
			script: """
			"${SRCROOT}/Scripts/run_swiftlint.sh" "\(path)"
			""",
			name: "SwiftLint",
			basedOnDependencyAnalysis: false
		)
	}
}

/// Build phase scripts applied to all source targets (app and framework modules).
///
/// Add new project-wide build phases here — they will apply to every source target.
func sourceTargetScripts(path: String) -> [TargetScript] {
	[.swiftLint(path: path)]
}
