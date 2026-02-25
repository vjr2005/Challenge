import Foundation
import ProjectDescription

/// Generates `Package.swift` files for SPM local packages.
///
/// Called from `SPMModule.init` during manifest evaluation to auto-generate
/// the `Package.swift` that defines each module's targets and dependencies.
/// Follows the same manifest-time side-effect pattern as `TestPlanGenerator`.
enum PackageSwiftGenerator {
	// swiftlint:disable:next function_body_length
	static func generate(
		directory: String,
		name: String,
		dependencies: [ModuleDependency],
		testDependencies: [ModuleDependency],
		snapshotTestDependencies: [ModuleDependency],
		settingsOverrides: SettingsDictionary,
		fileSystem: ModuleFileSystem,
		config: ProjectConfig
	) {
		let isNonisolated = isNonisolatedModule(settingsOverrides: settingsOverrides)
		let settingsVarName = isNonisolated ? "nonisolatedSettings" : "mainActorSettings"

		let allDeps = dependencies + testDependencies + snapshotTestDependencies
		let packageDeps = collectPackageDependencies(from: allDeps, sourceDirectory: directory)
		let sourceTargetDeps = dependencies.map { targetDependencyEntry(for: $0) }

		let hasTests = fileSystem.hasUnitTests || fileSystem.hasSnapshotTests
		let testTargetDeps = hasTests
			? buildTestTargetDependencies(
				name: name,
				hasMocks: fileSystem.hasMocks,
				testDependencies: testDependencies,
				snapshotTestDependencies: snapshotTestDependencies
			)
			: []

		var lines: [String] = []

		// Header
		lines.append("// swift-tools-version: \(config.swiftToolsVersion)")
		lines.append("import PackageDescription")
		lines.append("")

		// Swift settings
		appendSwiftSettings(to: &lines, isNonisolated: isNonisolated)
		lines.append("")

		// Package definition
		lines.append("let package = Package(")
		lines.append("\tname: \"\(name)\",")
		lines.append("\tplatforms: [.iOS(.v\(config.iosMajorVersion))],")

		// Products
		appendProducts(to: &lines, name: name, hasMocks: fileSystem.hasMocks)

		// Package-level dependencies
		if !packageDeps.isEmpty {
			lines.append("\tdependencies: [")
			for dep in packageDeps {
				lines.append("\t\t\(dep),")
			}
			lines.append("\t],")
		}

		// Targets
		lines.append("\ttargets: [")
		appendSourceTarget(
			to: &lines,
			name: name,
			sourceTargetDeps: sourceTargetDeps,
			hasResources: fileSystem.hasResources,
			settingsVarName: settingsVarName
		)

		if fileSystem.hasMocks {
			appendMocksTarget(to: &lines, name: name, settingsVarName: settingsVarName)
		}

		if hasTests {
			appendTestTarget(
				to: &lines,
				name: name,
				testTargetDeps: testTargetDeps,
				fileSystem: fileSystem,
				settingsVarName: settingsVarName
			)
		}

		lines.append("\t]")
		lines.append(")")
		lines.append("")

		let content = lines.joined(separator: "\n")
		let path = "\(workspaceRoot)/\(directory)/Package.swift"
		// swiftlint:disable:next force_try
		try! content.write(toFile: path, atomically: true, encoding: .utf8)
	}
}

// MARK: - Detection

private extension PackageSwiftGenerator {
	static func isNonisolatedModule(settingsOverrides: SettingsDictionary) -> Bool {
		if case let .string(value) = settingsOverrides["SWIFT_DEFAULT_ACTOR_ISOLATION"],
			value == "nonisolated"
		{
			return true
		}
		return false
	}
}

// MARK: - Path Computation

private extension PackageSwiftGenerator {
	/// Computes relative path from source directory to dependency directory.
	///
	/// Example: from `"Features/Character"` to `"Libraries/Core"` → `"../../Libraries/Core"`.
	static func relativePath(from source: String, to destination: String) -> String {
		let sourceComponents = source.split(separator: "/").map(String.init)
		let destComponents = destination.split(separator: "/").map(String.init)

		var commonLength = 0
		for index in 0..<min(sourceComponents.count, destComponents.count) {
			if sourceComponents[index] == destComponents[index] {
				commonLength += 1
			} else {
				break
			}
		}

		let ups = Array(repeating: "..", count: sourceComponents.count - commonLength)
		let remaining = destComponents[commonLength...]

		return (ups + remaining).joined(separator: "/")
	}

	/// Package identity from a module directory (last path component).
	///
	/// Example: `"Libraries/Core"` → `"Core"`.
	static func packageIdentity(for directory: String) -> String {
		String(directory.split(separator: "/").last ?? Substring(directory))
	}
}

// MARK: - Dependency Collection

private extension PackageSwiftGenerator {
	/// Collects unique package-level dependency entries, preserving order of first appearance.
	static func collectPackageDependencies(
		from allDeps: [ModuleDependency],
		sourceDirectory: String
	) -> [String] {
		var seen: Set<String> = []
		var result: [String] = []

		for dep in allDeps {
			switch dep {
			case let .module(module):
				if seen.insert(module.directory).inserted {
					let path = relativePath(from: sourceDirectory, to: module.directory)
					result.append(".package(path: \"\(path)\")")
				}
			case let .moduleMocks(module):
				if seen.insert(module.directory).inserted {
					let path = relativePath(from: sourceDirectory, to: module.directory)
					result.append(".package(path: \"\(path)\")")
				}
			case let .external(package):
				if seen.insert(package.url).inserted {
					result.append(".package(url: \"\(package.url)\", from: \"\(package.version)\")")
				}
			}
		}

		return result
	}

	/// Generates a target-level dependency entry string.
	static func targetDependencyEntry(for dep: ModuleDependency) -> String {
		switch dep {
		case let .module(module):
			let pkgId = packageIdentity(for: module.directory)
			return ".product(name: \"\(module.name)\", package: \"\(pkgId)\")"
		case let .moduleMocks(module):
			let pkgId = packageIdentity(for: module.directory)
			return ".product(name: \"\(module.name)Mocks\", package: \"\(pkgId)\")"
		case let .external(package):
			return ".product(name: \"\(package.productName)\", package: \"\(package.packageIdentity)\")"
		}
	}

	/// Builds deduplicated test target dependencies from test and snapshot dependency arrays.
	static func buildTestTargetDependencies(
		name: String,
		hasMocks: Bool,
		testDependencies: [ModuleDependency],
		snapshotTestDependencies: [ModuleDependency]
	) -> [String] {
		var result: [String] = ["\"\(name)\""]

		if hasMocks {
			result.append("\"\(name)Mocks\"")
		}

		var seenProducts: Set<String> = []
		for dep in testDependencies + snapshotTestDependencies {
			let productKey = targetDependencyProductKey(for: dep)
			if seenProducts.insert(productKey).inserted {
				result.append(targetDependencyEntry(for: dep))
			}
		}

		return result
	}

	/// Returns a unique key for deduplication of target-level dependencies.
	static func targetDependencyProductKey(for dep: ModuleDependency) -> String {
		switch dep {
		case let .module(module):
			module.name
		case let .moduleMocks(module):
			"\(module.name)Mocks"
		case let .external(package):
			package.productName
		}
	}
}

// MARK: - Line Builders

private extension PackageSwiftGenerator {
	static func appendSwiftSettings(to lines: inout [String], isNonisolated: Bool) {
		if isNonisolated {
			lines.append("let nonisolatedSettings: [SwiftSetting] = [")
			lines.append("\t.enableExperimentalFeature(\"ApproachableConcurrency\"),")
			lines.append("]")
		} else {
			lines.append("let mainActorSettings: [SwiftSetting] = [")
			lines.append("\t.defaultIsolation(MainActor.self),")
			lines.append("\t.enableExperimentalFeature(\"ApproachableConcurrency\"),")
			lines.append("]")
		}
	}

	static func appendProducts(to lines: inout [String], name: String, hasMocks: Bool) {
		lines.append("\tproducts: [")
		lines.append("\t\t.library(name: \"\(name)\", targets: [\"\(name)\"]),")
		if hasMocks {
			lines.append("\t\t.library(name: \"\(name)Mocks\", targets: [\"\(name)Mocks\"]),")
		}
		lines.append("\t],")
	}

	static func appendSourceTarget(
		to lines: inout [String],
		name: String,
		sourceTargetDeps: [String],
		hasResources: Bool,
		settingsVarName: String
	) {
		lines.append("\t\t.target(")
		lines.append("\t\t\tname: \"\(name)\",")
		if !sourceTargetDeps.isEmpty {
			lines.append("\t\t\tdependencies: [")
			for dep in sourceTargetDeps {
				lines.append("\t\t\t\t\(dep),")
			}
			lines.append("\t\t\t],")
		}
		lines.append("\t\t\tpath: \"Sources\",")
		if hasResources {
			lines.append("\t\t\tresources: [")
			lines.append("\t\t\t\t.process(\"Resources\"),")
			lines.append("\t\t\t],")
		}
		lines.append("\t\t\tswiftSettings: \(settingsVarName)")
		lines.append("\t\t),")
	}

	static func appendMocksTarget(to lines: inout [String], name: String, settingsVarName: String) {
		lines.append("\t\t.target(")
		lines.append("\t\t\tname: \"\(name)Mocks\",")
		lines.append("\t\t\tdependencies: [\"\(name)\"],")
		lines.append("\t\t\tpath: \"Mocks\",")
		lines.append("\t\t\tswiftSettings: \(settingsVarName)")
		lines.append("\t\t),")
	}

	static func appendTestTarget(
		to lines: inout [String],
		name: String,
		testTargetDeps: [String],
		fileSystem: ModuleFileSystem,
		settingsVarName: String
	) {
		lines.append("\t\t.testTarget(")
		lines.append("\t\t\tname: \"\(name)Tests\",")
		lines.append("\t\t\tdependencies: [")
		for dep in testTargetDeps {
			lines.append("\t\t\t\t\(dep),")
		}
		lines.append("\t\t\t],")
		lines.append("\t\t\tpath: \"Tests\",")

		let exclusions = fileSystem.snapshotExclusions
		if !exclusions.isEmpty {
			lines.append("\t\t\texclude: [")
			for exclusion in exclusions {
				lines.append("\t\t\t\t\"\(exclusion)\",")
			}
			lines.append("\t\t\t],")
		}

		var testResources: [String] = []
		if fileSystem.hasSharedFixtures {
			testResources.append(".process(\"Shared/Fixtures\")")
		}
		if fileSystem.hasSharedResources {
			testResources.append(".process(\"Shared/Resources\")")
		}
		if !testResources.isEmpty {
			lines.append("\t\t\tresources: [")
			for resource in testResources {
				lines.append("\t\t\t\t\(resource),")
			}
			lines.append("\t\t\t],")
		}

		lines.append("\t\t\tswiftSettings: \(settingsVarName)")
		lines.append("\t\t),")
	}
}
