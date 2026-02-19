import ProjectDescription

/// Represents the different build environments for the app.
enum Environment: String, CaseIterable {
	case dev
	case staging
	case prod

	/// Display name for the scheme.
	var schemeName: String {
		switch self {
		case .dev: "\(appName) (Dev)"
		case .staging: "\(appName) (Staging)"
		case .prod: "\(appName) (Prod)"
		}
	}

	/// Bundle identifier suffix for each environment.
	var bundleIdSuffix: String {
		switch self {
		case .dev: ".dev"
		case .staging: ".staging"
		case .prod: ""
		}
	}

	/// Full bundle identifier for each environment.
	var bundleId: String {
		"com.app.\(appName)\(bundleIdSuffix)"
	}

	/// App icon asset name for each environment.
	var appIconName: String {
		switch self {
		case .dev: "AppIconDev"
		case .staging: "AppIconStaging"
		case .prod: "AppIcon"
		}
	}

	/// Debug configuration name for running the app.
	var debugConfigurationName: ConfigurationName {
		switch self {
		case .dev: "Debug"
		case .staging: "Debug-Staging"
		case .prod: "Debug-Prod"
		}
	}

	/// Release configuration name for archiving.
	var releaseConfigurationName: ConfigurationName {
		switch self {
		case .dev: "Release"
		case .staging: "Staging"
		case .prod: "Release"
		}
	}

	/// Target settings for this environment.
	var targetSettings: Configuration {
		let settings: SettingsDictionary = [
			"PRODUCT_BUNDLE_IDENTIFIER": .string(bundleId),
			"ASSETCATALOG_COMPILER_APPICON_NAME": .string(appIconName),
		]

		switch self {
		case .dev:
			return .debug(name: "Debug", settings: settings)
		case .staging:
			return .debug(name: "Debug-Staging", settings: settings)
		case .prod:
			return .debug(name: "Debug-Prod", settings: settings)
		}
	}

	/// Release target settings for this environment.
	var releaseTargetSettings: Configuration {
		// Code Signing Configuration
		// --------------------------
		// Current: Disabled for building without Apple Developer account.
		// With Apple ID: Replace with these values:
		//   "CODE_SIGN_IDENTITY": .string("Apple Development"),
		//   "CODE_SIGNING_REQUIRED": .string("YES"),
		//   "CODE_SIGNING_ALLOWED": .string("YES"),
		//   "DEVELOPMENT_TEAM": .string("YOUR_TEAM_ID"),
		let codeSigningSettings: SettingsDictionary = [
			"CODE_SIGN_IDENTITY": .string(""),
			"CODE_SIGNING_REQUIRED": .string("NO"),
			"CODE_SIGNING_ALLOWED": .string("NO"),
		]

		let settings: SettingsDictionary = [
			"PRODUCT_BUNDLE_IDENTIFIER": .string(bundleId),
			"ASSETCATALOG_COMPILER_APPICON_NAME": .string(appIconName),
		].merging(codeSigningSettings) { _, new in new }

		switch self {
		case .dev:
			return .release(name: "Release", settings: settings)
		case .staging:
			return .release(name: "Staging", settings: settings)
		case .prod:
			return .release(name: "Release", settings: settings)
		}
	}
}

// MARK: - App Target Settings

extension Environment {
	/// All configurations for the app target.
	static var appTargetConfigurations: [Configuration] {
		[
			Environment.dev.targetSettings,
			Environment.staging.targetSettings,
			Environment.prod.targetSettings,
			Environment.staging.releaseTargetSettings,
			Environment.prod.releaseTargetSettings,
		]
	}
}
