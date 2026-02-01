import ProjectDescription

public enum HomeModule {
    public static let module = FrameworkModule.create(
        name: "Home",
        baseFolder: "Features",
        path: "Home",
        dependencies: [
            .target(name: "\(appName)Core"),
            .target(name: "\(appName)DesignSystem"),
            .target(name: "\(appName)Resources"),
            .external(name: "Lottie"),
        ],
        testDependencies: [
            .target(name: "\(appName)CoreMocks"),
        ],
        snapshotTestDependencies: [
            .target(name: "\(appName)CoreMocks"),
        ]
    )

    public static let targetReferences: [TargetReference] = [
        .target("\(appName)Home"),
    ]
}
