import Foundation

/// Generates an `.xctestplan` JSON file from module definitions.
///
/// Used by `ModuleAggregation` to auto-generate the test plan that aggregates
/// all module test targets and code coverage targets. Supports any mix of
/// SPM and Framework modules via `ModuleContract.containerPath`.
enum TestPlanGenerator {
	/// Generates the `.xctestplan` file and returns its filename.
	///
	/// - Parameters:
	///   - appName: The app target name (e.g., `"Challenge"`).
	///   - modules: All project modules to include in the test plan.
	/// - Returns: The test plan filename (e.g., `"Challenge.xctestplan"`).
	static func generate(
		appName: String,
		modules: [any ModuleContract]
	) -> String {
		let testPlanName = "\(appName).xctestplan"

		var coverageTargets: [[String: String]] = [
			["containerPath": "container:", "identifier": appName, "name": appName],
		]
		var testTargets: [[String: Any]] = []

		for module in modules {
			if module.includeInCoverage {
				coverageTargets.append([
					"containerPath": module.containerPath,
					"identifier": module.name,
					"name": module.name,
				])
			}

			let fileSystem = ModuleFileSystem(directory: module.directory, appName: appName)
			if fileSystem.hasUnitTests {
				testTargets.append([
					"target": [
						"containerPath": module.containerPath,
						"identifier": "\(module.name)Tests",
						"name": "\(module.name)Tests",
					],
				])
			}

			// Framework modules have separate snapshot test targets.
			// SPM modules merge snapshots into the main test target (already covered above).
			if fileSystem.hasSnapshotTests, module.packageReference == nil {
				let snapshotTestsName = "\(module.name)SnapshotTests"
				testTargets.append([
					"target": [
						"containerPath": module.containerPath,
						"identifier": snapshotTestsName,
						"name": snapshotTestsName,
					],
				])
			}
		}

		let testPlan: [String: Any] = [
			"configurations": [Any](),
			"defaultOptions": [
				"codeCoverage": true,
				"codeCoverageTargets": coverageTargets,
			],
			"testTargets": testTargets,
			"version": 1,
		]

		// swiftlint:disable:next force_try
		let data = try! JSONSerialization.data(
			withJSONObject: testPlan,
			options: [.prettyPrinted, .sortedKeys]
		)
		let json = String(data: data, encoding: .utf8)!
		let path = "\(workspaceRoot)/\(testPlanName)"
		// swiftlint:disable:next force_try
		try! json.write(toFile: path, atomically: true, encoding: .utf8)

		return testPlanName
	}
}
