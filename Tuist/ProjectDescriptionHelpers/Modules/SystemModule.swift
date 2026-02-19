import ProjectDescription

public enum SystemModule {
    public static let module = FrameworkModule.create(
        name: "System",
        baseFolder: "Features",
        path: "System",
        dependencies: [
			CoreModule.targetDependency,
            .target(name: "\(appName)Resources"),
			DesignSystemModule.targetDependency,
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
