import Foundation
import ProjectDescription

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

	/// Tuist product type override (e.g., `.framework`).
	/// When `nil`, Tuist uses the default product type for the package.
	public let productType: Product?

	/// Package identity derived from the URL's last path component.
	///
	/// Example: `"https://github.com/airbnb/lottie-ios"` → `"lottie-ios"`.
	var packageIdentity: String {
		URL(string: url)?.lastPathComponent ?? productName
	}

	public init(productName: String, url: String, version: String, productType: Product? = nil) {
		self.productName = productName
		self.url = url
		self.version = version
		self.productType = productType
	}
}

// MARK: - Collection Helpers

extension [ExternalPackage] {
	/// Product type overrides for `PackageSettings`.
	/// Only includes packages with an explicit `productType`.
	public var productTypes: [String: Product] {
		reduce(into: [:]) { result, package in
			if let productType = package.productType {
				result[package.productName] = productType
			}
		}
	}
}
