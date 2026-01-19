import ProjectDescription

/// Helper for creating build configurations consistently across the project.
public enum BuildConfiguration {
	/// All build configurations for the project.
	public static let all: [Configuration] = [
		debug,
		debugStaging,
		debugProd,
		staging,
		release,
	]

	public static let debug: Configuration = .debug(
		name: "Debug",
		settings: [
			"SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) DEBUG",
		]
	)

	public static let debugStaging: Configuration = .debug(
		name: "Debug-Staging",
		settings: [
			"SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) DEBUG DEBUG_STAGING",
		]
	)

	public static let debugProd: Configuration = .debug(
		name: "Debug-Prod",
		settings: [
			"SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) DEBUG DEBUG_PROD",
		]
	)

	public static let staging: Configuration = .release(
		name: "Staging",
		settings: [
			"SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) STAGING",
		]
	)

	public static let release: Configuration = .release(
		name: "Release",
		settings: [
			"SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) PRODUCTION",
		]
	)
}
