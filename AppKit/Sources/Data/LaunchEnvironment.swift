import Foundation

public struct LaunchEnvironment {
	public let apiBaseURL: URL?

	public init(environment: [String: String] = ProcessInfo.processInfo.environment) {
		apiBaseURL = environment["API_BASE_URL"].flatMap(URL.init)
	}
}
