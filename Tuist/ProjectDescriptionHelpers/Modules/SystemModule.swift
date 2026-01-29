import ProjectDescription

public enum SystemModule {
    public static let module = FrameworkModule.create(
        name: "System",
        baseFolder: "Features",
        path: "System",
        dependencies: [
            .target(name: "\(appName)Core"),
            .target(name: "\(appName)Resources"),
            .target(name: "\(appName)DesignSystem"),
        ],
        testDependencies: [
            .target(name: "\(appName)CoreMocks"),
        ]
    )

    public static let targetReferences: [TargetReference] = [
        .target("\(appName)System"),
    ]
}
