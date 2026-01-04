import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Challenge",
    settings: .settings(
        base: ["SWIFT_VERSION": .string(swiftVersion)]
    ),
    targets: [
        .target(
            name: "Challenge",
            destinations: [.iPhone, .iPad],
            product: .app,
            bundleId: "com.app.Challenge",
            deploymentTargets: developmentTarget,
            infoPlist: .extendingDefault(with: [
                "UILaunchStoryboardName": "LaunchScreen",
                "UISupportedInterfaceOrientations": [
                    "UIInterfaceOrientationPortrait",
                    "UIInterfaceOrientationLandscapeLeft",
                    "UIInterfaceOrientationLandscapeRight",
                    "UIInterfaceOrientationPortraitUpsideDown"
                ],
                "UISupportedInterfaceOrientations~ipad": [
                    "UIInterfaceOrientationPortrait",
                    "UIInterfaceOrientationPortraitUpsideDown",
                    "UIInterfaceOrientationLandscapeLeft",
                    "UIInterfaceOrientationLandscapeRight"
                ]
            ]),
            sources: ["App/Sources/**"],
            resources: ["App/Sources/Resources/**"]
        ),
        .target(
            name: "ChallengeTests",
            destinations: [.iPhone, .iPad],
            product: .unitTests,
            bundleId: "com.app.ChallengeTests",
            deploymentTargets: developmentTarget,
            infoPlist: .default,
            sources: ["App/Tests/**"]
        ),
        .target(
            name: "ChallengeUITests",
            destinations: [.iPhone, .iPad],
            product: .uiTests,
            bundleId: "com.app.ChallengeUITests",
            deploymentTargets: developmentTarget,
            infoPlist: .default,
            sources: ["App/UITests/**"]
        )
    ]
)
