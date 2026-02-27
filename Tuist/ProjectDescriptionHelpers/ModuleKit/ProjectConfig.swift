import ProjectDescription

/// Bundles all project-wide settings into a single typed value.
public struct ProjectConfig: @unchecked Sendable {
	public let appName: String
	public let swiftToolsVersion: String
	public let iosMajorVersion: String
	public let destinations: Destinations
	public let developmentTarget: DeploymentTargets
	public let baseSettings: SettingsDictionary

	public init(
		appName: String,
		swiftToolsVersion: String,
		iosMajorVersion: String,
		destinations: Destinations,
		developmentTarget: DeploymentTargets,
		baseSettings: SettingsDictionary
	) {
		self.appName = appName
		self.swiftToolsVersion = swiftToolsVersion
		self.iosMajorVersion = iosMajorVersion
		self.destinations = destinations
		self.developmentTarget = developmentTarget
		self.baseSettings = baseSettings
	}
}
