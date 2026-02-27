import Foundation

/// Generates an `.xctestplan` JSON file from module definitions.
///
/// Used by `ModuleAggregation` to auto-generate the test plan that aggregates
/// all module test targets and code coverage targets. Supports any mix of
/// SPM and Framework modules via `ModuleContract.containerPath`.
///
/// **Coverage filtering:** Uses `codeCoverage.targets` to tell Xcode to
/// "Gather coverage for some targets." Only modules with
/// `includeInCoverage == true` are listed. All targets reference
/// the xcodeproj container, which works for both framework targets
/// and SPM local packages resolved through the project.
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

		let appContainerPath: String = switch ModuleStrategy.active {
		case .spm: "container:"
		case .framework: "container:\(appName).xcodeproj"
		}

		var coverageTargets: [TestPlanCoverageTarget] = [
			TestPlanCoverageTarget(containerPath: appContainerPath, identifier: appName, name: appName),
		]
		var testTargets: [TestPlanTestTargetEntry] = []

		for module in modules {
			if module.includeInCoverage {
				coverageTargets.append(
					TestPlanCoverageTarget(
						containerPath: module.containerPath,
						identifier: module.name,
						name: module.name
					)
				)
			}

			let fileSystem = ModuleFileSystem(directory: module.directory, appName: appName)
			if fileSystem.hasUnitTests {
				testTargets.append(
					TestPlanTestTargetEntry(
						target: TestPlanTestTarget(
							containerPath: module.containerPath,
							identifier: "\(module.name)Tests",
							name: "\(module.name)Tests"
						)
					)
				)
			}

			// Framework modules have separate snapshot test targets.
			// SPM modules merge snapshots into the main test target (already covered above).
			if fileSystem.hasSnapshotTests, module.packageReference == nil {
				let snapshotTestsName = "\(module.name)SnapshotTests"
				testTargets.append(
					TestPlanTestTargetEntry(
						target: TestPlanTestTarget(
							containerPath: module.containerPath,
							identifier: snapshotTestsName,
							name: snapshotTestsName
						)
					)
				)
			}
		}

		let testPlan = TestPlan(
			configurations: [
				TestPlanConfiguration(name: "Test Scheme Action"),
			],
			defaultOptions: TestPlanDefaultOptions(
				codeCoverage: TestPlanCodeCoverage(targets: coverageTargets)
			),
			testTargets: testTargets,
			version: 1
		)

		let encoder = JSONEncoder()
		encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

		let data: Data
		do {
			data = try encoder.encode(testPlan)
		} catch {
			fatalError("Failed to encode test plan '\(testPlanName)': \(error)")
		}

		guard let json = String(data: data, encoding: .utf8) else {
			fatalError("Failed to encode test plan '\(testPlanName)' as UTF-8")
		}

		let path = "\(workspaceRoot)/\(testPlanName)"
		do {
			try (json + "\n").write(toFile: path, atomically: true, encoding: .utf8)
		} catch {
			fatalError("Failed to write test plan at \(path): \(error)")
		}

		return testPlanName
	}
}
