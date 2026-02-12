import CryptoKit
import Foundation
import UIKit

/// Disk-based image cache with TTL expiration and LRU eviction.
actor ImageDiskCache {
	private let configuration: DiskCacheConfiguration
	private let fileSystem: FileSystemContract
	private var isEvicting = false

	init(configuration: DiskCacheConfiguration, fileSystem: FileSystemContract) {
		self.configuration = configuration
		self.fileSystem = fileSystem
	}

	func image(for url: URL) async -> UIImage? {
		let fileURL = fileURL(for: url)

		guard let data = try? await fileSystem.contents(at: fileURL) else {
			return nil
		}

		// If attributes can't be read (e.g., file evicted by a concurrent task between reading
		// data and reading attributes), return the image from already-read data rather than
		// discarding it. The data is valid and already in memory.
		guard let attributes = try? await fileSystem.fileAttributes(at: fileURL) else {
			try? await fileSystem.removeItem(at: fileURL)
			return UIImage(data: data)
		}

		if attributes.created.addingTimeInterval(configuration.timeToLive) < Date() {
			try? await fileSystem.removeItem(at: fileURL)
			return nil
		}

		try? await fileSystem.updateModificationDate(at: fileURL) // Mark as recently used for LRU eviction
		return UIImage(data: data)
	}

	func store(_ data: Data, for url: URL) async {
		guard !data.isEmpty else {
			return
		}

		try? await fileSystem.createDirectory(at: configuration.directory)

		let fileURL = fileURL(for: url)

		guard (try? await fileSystem.write(data, to: fileURL)) != nil else {
			return
		}

		await enforceMaxSize()
	}

	func remove(for url: URL) async {
		let fileURL = fileURL(for: url)
		try? await fileSystem.removeItem(at: fileURL)
	}

	func removeAll() async {
		guard let files = try? await fileSystem.contentsOfDirectory(at: configuration.directory) else {
			return
		}
		for file in files {
			try? await fileSystem.removeItem(at: file)
		}
	}
}

// MARK: - Private

private extension ImageDiskCache {
	func fileURL(for url: URL) -> URL {
		let hash = SHA256.hash(data: Data(url.absoluteString.utf8))
		let fileName = hash.compactMap { String(format: "%02x", $0) }.joined()
		return configuration.directory.appendingPathComponent(fileName)
	}

	/// Removes least recently used files until total size is within `maxSize`.
	/// Uses `isEvicting` flag to prevent concurrent evictions from interleaving,
	/// which could cause stale snapshots and redundant deletions.
	func enforceMaxSize() async {
		guard !isEvicting else { return }
		isEvicting = true
		defer { isEvicting = false }

		guard let files = try? await fileSystem.contentsOfDirectory(at: configuration.directory) else {
			return
		}

		var totalSize = 0
		var fileInfos: [(url: URL, size: Int, modified: Date)] = []

		for file in files {
			guard let attributes = try? await fileSystem.fileAttributes(at: file) else {
				try? await fileSystem.removeItem(at: file)
				continue
			}
			totalSize += attributes.size
			fileInfos.append((url: file, size: attributes.size, modified: attributes.modified))
		}

		guard totalSize > configuration.maxSize else {
			return
		}

		fileInfos.sort { $0.modified < $1.modified }

		for fileInfo in fileInfos {
			guard totalSize > configuration.maxSize else {
				break
			}
			try? await fileSystem.removeItem(at: fileInfo.url)
			totalSize -= fileInfo.size
		}
	}
}
