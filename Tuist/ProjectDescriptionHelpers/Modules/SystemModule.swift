import ProjectDescription

public enum SystemModule {
    public static let module = FrameworkModule.create(
        name: "System",
        baseFolder: "Features",
        path: "System",
        dependencies: [
			CoreModule.targetDependency,
            .target(name: "\(appName)Resources"),
            .target(name: "\(appName)DesignSystem"),
        ],
        testDependencies: [
			CoreModule.mocksTargetDependency
        ],
        snapshotTestDependencies: [
			CoreModule.mocksTargetDependency
        ]
    )

    public static let targetReferences: [TargetReference] = [
        .target("\(appName)System"),
    ]
}
