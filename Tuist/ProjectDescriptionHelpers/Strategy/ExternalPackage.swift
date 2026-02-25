import Foundation

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

// MARK: - Shared Constants

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
