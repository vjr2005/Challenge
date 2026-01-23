import ProjectDescription

public enum HomeModule {
    public static let module = FrameworkModule.create(
        name: "Home",
        baseFolder: "Features",
        path: "Home",
        dependencies: [
            .target(name: "\(appName)Core"),
            .target(name: "\(appName)Shared"),
        ],
        testDependencies: [
            .target(name: "\(appName)CoreMocks"),
            .external(name: "SnapshotTesting"),
        ]
    )

    public static let targetReferences: [TargetReference] = [
        .target("\(appName)Home"),
    ]
}
