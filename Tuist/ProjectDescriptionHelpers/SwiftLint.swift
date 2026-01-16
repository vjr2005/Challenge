import ProjectDescription

public enum SwiftLint {
	/// Returns a build script that runs SwiftLint.
	/// - Parameter path: Optional path to lint. If nil, lints the entire project.
	public static func script(path: String? = nil) -> TargetScript {
		let lintPath = path ?? "."
		return .post(
			script: """
			"${SRCROOT}/Scripts/run_swiftlint.sh" "\(lintPath)"
			""",
			name: "SwiftLint",
			basedOnDependencyAnalysis: false
		)
	}
}
