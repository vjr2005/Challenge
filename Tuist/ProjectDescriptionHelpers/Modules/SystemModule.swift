import ProjectDescription

public enum SystemModule {
    public static let module = FrameworkModule.create(
        name: "System",
        baseFolder: "Features",
        path: "System",
        dependencies: [
			CoreModule.targetDependency,
			ResourcesModule.targetDependency,
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
