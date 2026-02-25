import Foundation
import ProjectDescription

// MARK: - External Package

/// Metadata for an external SPM dependency (URL + version).
///
/// Used by `ModuleDependency.external` to carry enough information
/// for both Tuist target resolution and `Package.swift` generation.
public struct ExternalPackage: Sendable {
	/// The SPM product name (e.g., `"Lottie"`, `"SnapshotTesting"`).
	public let productName: String

	/// The package repository URL.
	public let url: String

	/// The minimum version requirement (used with `.upToNextMajor`).
	public let version: String

	/// Package identity derived from the URL's last path component.
	///
	/// Example: `"https://github.com/airbnb/lottie-ios"` → `"lottie-ios"`.
	var packageIdentity: String {
		URL(string: url)?.lastPathComponent ?? productName
	}

	public init(productName: String, url: String, version: String) {
		self.productName = productName
		self.url = url
		self.version = version
	}
}

// MARK: - Shared External Package Constants

public let snapshotTestingPackage = ExternalPackage(
	productName: "SnapshotTesting",
	url: "https://github.com/pointfreeco/swift-snapshot-testing",
	version: "1.17.0"
)

public let lottiePackage = ExternalPackage(
	productName: "Lottie",
	url: "https://github.com/airbnb/lottie-ios",
	version: "4.6.0"
)

// MARK: - Module Dependency

/// A dependency reference for module configuration.
///
/// Used in module init parameters to declare dependencies on other modules
/// or external SPM packages.
public enum ModuleDependency {
	/// Dependency on a module's main source target.
	case module(any ModuleContract)

	/// Dependency on a module's mocks target.
	case moduleMocks(any ModuleContract)

	/// Dependency on an external SPM package product.
	case external(ExternalPackage)
}

// MARK: - Target Resolution

extension ModuleDependency {
	/// Resolves the dependency to a `TargetDependency`.
	var targetDependency: TargetDependency {
		switch self {
		case let .module(module):
			module.targetDependency
		case let .moduleMocks(module):
			module.mocksTargetDependency
		case let .external(package):
			.external(name: package.productName)
		}
	}
}
