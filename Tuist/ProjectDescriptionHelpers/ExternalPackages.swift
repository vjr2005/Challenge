/// External SPM dependencies used by this project.

import ProjectDescription

public let snapshotTestingPackage = ExternalPackage(
	productName: "SnapshotTesting",
	url: "https://github.com/pointfreeco/swift-snapshot-testing",
	version: "1.17.0",
	productType: .framework
)

public let lottiePackage = ExternalPackage(
	productName: "Lottie",
	url: "https://github.com/airbnb/lottie-ios",
	version: "4.6.0",
	productType: .framework
)

public let swiftMockServerPackage = ExternalPackage(
	productName: "SwiftMockServerBinary",
	url: "https://github.com/vjr2005/SwiftMockServer",
	version: "1.1.1",
	productType: .framework
)

/// All external SPM packages. Used by `Package.swift` to derive
/// `PackageSettings.productTypes` and `Package.dependencies`.
public let allExternalPackages: [ExternalPackage] = [
	snapshotTestingPackage,
	lottiePackage,
	swiftMockServerPackage,
]
