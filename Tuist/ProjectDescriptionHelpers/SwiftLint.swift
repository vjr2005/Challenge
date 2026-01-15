import ProjectDescription

public enum SwiftLint {
	/// Returns a build script that runs SwiftLint.
	/// - Parameter path: Optional path to lint. If nil, lints the entire project.
	public static func script(path: String? = nil) -> TargetScript {
		let lintPath = path ?? "."
		return .post(
			script: """
			export PATH="/opt/homebrew/bin:$PATH"
			if command -v swiftlint >/dev/null 2>&1; then
				swiftlint lint --config "${SRCROOT}/.swiftlint.yml" "\(lintPath)"
			else
				echo "warning: SwiftLint not installed. Run ./setup.sh to install."
			fi
			""",
			name: "SwiftLint",
			basedOnDependencyAnalysis: false
		)
	}
}
