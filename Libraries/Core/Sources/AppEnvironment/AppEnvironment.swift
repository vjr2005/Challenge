import Foundation

/// Application environment configuration.
public enum AppEnvironment {
	case development
	case staging
	case production

	/// Current environment based on build configuration.
	public static var current: Self {
		#if DEBUG_PROD
		.production
		#elseif DEBUG_STAGING
		.staging
		#elseif DEBUG
		.development
		#elseif STAGING
		.staging
		#else
		.production
		#endif
	}

	/// Whether the current environment is a debug build.
	public var isDebug: Bool {
		self == .development
	}

	/// Whether the current environment is a release build.
	public var isRelease: Bool {
		self == .production
	}
}
