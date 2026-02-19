import ProjectDescription

public enum HomeModule {
    public static let module = FrameworkModule.create(
        name: "Home",
        baseFolder: "Features",
        path: "Home",
        dependencies: [
			CoreModule.targetDependency,
            .target(name: "\(appName)DesignSystem"),
            .target(name: "\(appName)Resources"),
            .external(name: "Lottie")
        ],
        testDependencies: [
			CoreModule.mocksTargetDependency
        ],
        snapshotTestDependencies: [
			CoreModule.mocksTargetDependency
        ]
    )

    public static let targetReferences: [TargetReference] = [
        .target("\(appName)Home"),
    ]
}
