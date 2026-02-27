import ProjectDescription

/// Module implementation that integrates as an SPM local package.
///
/// Each module is an independent SPM package with its own `Package.swift`.
/// The root project references them via `packages:` and resolves dependencies through SPM.
/// Tests run via an auto-generated `.xctestplan` file.
public struct SPMModule: ModuleContract, @unchecked Sendable {
	public let directory: String
	public let name: String
	public let includeInCoverage: Bool
	public let packageTargetSettings: [String: Settings]

	// MARK: - SPM: Computed (always empty)

	public var targets: [Target] { [] }
	public var schemes: [Scheme] { [] }
	public var testableTargets: [TestableTarget] { [] }
	public var codeCoverageTargets: [TargetReference] { [] }

	// MARK: - SPM: Computed (derived from name)

	public var targetDependency: TargetDependency { .package(product: name) }
	public var mocksTargetDependency: TargetDependency { .package(product: "\(name)Mocks") }
	public var packageReference: Package? { .package(path: Path(stringLiteral: directory)) }
	public var containerPath: String { "container:\(directory)" }

	// MARK: - Init

	public init(
		directory: String,
		dependencies: [ModuleDependency] = [],
		testDependencies: [ModuleDependency] = [],
		snapshotTestDependencies: [ModuleDependency] = [],
		includeInCoverage: Bool = true,
		settingsOverrides: SettingsDictionary = [:],
		config: ProjectConfig = projectConfig
	) {
		Self.validateDependencies(
			directory: directory,
			dependencies: dependencies,
			testDependencies: testDependencies,
			snapshotTestDependencies: snapshotTestDependencies
		)

		let fileSystem = ModuleFileSystem(directory: directory, appName: config.appName)
		let name = fileSystem.targetName
		self.directory = directory
		self.name = name
		self.includeInCoverage = includeInCoverage

		let settings: Settings = .settings(
			base: config.baseSettings.merging(settingsOverrides) { _, new in new }
		)

		var targetSettings: [String: Settings] = [name: settings]

		if fileSystem.hasMocks {
			targetSettings["\(name)Mocks"] = settings
		}

		if fileSystem.hasUnitTests || fileSystem.hasSnapshotTests {
			targetSettings["\(name)Tests"] = settings
		}

		self.packageTargetSettings = targetSettings

		PackageSwiftGenerator.generate(
			directory: directory,
			name: name,
			dependencies: dependencies,
			testDependencies: testDependencies,
			snapshotTestDependencies: snapshotTestDependencies,
			settingsOverrides: settingsOverrides,
			fileSystem: fileSystem,
			config: config
		)
	}
}

// MARK: - Validation

extension SPMModule {
	/// Validates that no dependency points to a framework module.
	///
	/// SPM packages can only depend on other SPM packages or external dependencies.
	/// A `nil` `packageReference` indicates a framework module.
	private static func validateDependencies(
		directory: String,
		dependencies: [ModuleDependency],
		testDependencies: [ModuleDependency],
		snapshotTestDependencies: [ModuleDependency]
	) {
		let allDeps = dependencies + testDependencies + snapshotTestDependencies
		for dep in allDeps {
			switch dep {
			case let .module(module) where module.packageReference == nil:
				fatalError(
					"SPM module '\(directory)' cannot depend on framework module '\(module.directory)'. "
						+ "SPM packages can only depend on other SPM packages or external dependencies."
				)
			case let .moduleMocks(module) where module.packageReference == nil:
				fatalError(
					"SPM module '\(directory)' cannot depend on framework module mocks '\(module.directory)'. "
						+ "SPM packages can only depend on other SPM packages or external dependencies."
				)
			default:
				break
			}
		}
	}
}
