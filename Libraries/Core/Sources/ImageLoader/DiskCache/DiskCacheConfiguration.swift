import Foundation

struct DiskCacheConfiguration {
	let maxSize: Int
	let timeToLive: TimeInterval
	let directory: URL

	static let `default` = Self(
		maxSize: 100 * 1_024 * 1_024, // 100 MB
		timeToLive: 604_800, // 7 days
		directory: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
			.appendingPathComponent("ImageCache")
	)
}
