import Foundation

public struct DiskCacheConfiguration {
	let maxSize: Int
	let timeToLive: TimeInterval
	let directory: URL

	public init(maxSize: Int, timeToLive: TimeInterval, directory: URL) {
		self.maxSize = maxSize
		self.timeToLive = timeToLive
		self.directory = directory
	}

	public static let `default` = Self(
		maxSize: 100 * 1_024 * 1_024, // 100 MB
		timeToLive: 604_800, // 7 days
		directory: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
			.appendingPathComponent("ImageCache")
	)
}
