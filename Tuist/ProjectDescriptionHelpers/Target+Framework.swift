import ProjectDescription

public extension Target {
    static func createFramework(name: String,
                                destinations: ProjectDescription.Destinations = [.iPhone, .iPad]) -> Self {
        let targetName = "\(appName)\(name)"
        return .target(
            name: targetName,
            destinations: destinations,
            product: .framework,
            bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}.\(targetName)",
            sources: ["Libraries/\(name)/**"])
    }
}
