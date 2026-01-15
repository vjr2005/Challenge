import ProjectDescription

public let appName = "Challenge"

public let swiftVersion = "6.0" // It will use the latest version available (6+)

public let developmentTarget: DeploymentTargets = .iOS("16.0")

public let destinations: ProjectDescription.Destinations = [.iPhone, .iPad]
