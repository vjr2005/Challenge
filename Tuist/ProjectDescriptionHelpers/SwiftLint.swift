import ProjectDescription

enum SwiftLint {
	/// Returns a build script that runs SwiftLint.
	/// - Parameters:
	///   - path: Optional path to lint. If nil, lints the entire project.
	///   - workspaceRoot: Relative path from `$SRCROOT` to the workspace root. Defaults to `"."` (project at root).
	static func script(path: String? = nil, workspaceRoot: String = ".") -> TargetScript {
		let lintPath = path ?? "."
		return .post(
			script: """
			"${SRCROOT}/\(workspaceRoot)/Scripts/run_swiftlint.sh" "\(lintPath)"
			""",
			name: "SwiftLint",
			basedOnDependencyAnalysis: false
		)
	}
}
