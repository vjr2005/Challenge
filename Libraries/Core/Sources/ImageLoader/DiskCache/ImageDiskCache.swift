import CryptoKit
import Foundation
import UIKit

/// Disk-based image cache with TTL expiration and LRU eviction.
actor ImageDiskCache {
	private let configuration: DiskCacheConfiguration
	private let fileSystem: FileSystemContract
	private var directoryCreated = false

	init(configuration: DiskCacheConfiguration, fileSystem: FileSystemContract) {
		self.configuration = configuration
		self.fileSystem = fileSystem
	}

	func image(for url: URL) -> UIImage? {
		let fileURL = fileURL(for: url)

		guard let data = try? fileSystem.contents(at: fileURL) else {
			return nil
		}

		guard let attributes = try? fileSystem.fileAttributes(at: fileURL) else {
			try? fileSystem.removeItem(at: fileURL)
			return nil
		}

		if attributes.created.addingTimeInterval(configuration.timeToLive) < Date() {
			try? fileSystem.removeItem(at: fileURL)
			return nil
		}

		try? fileSystem.updateModificationDate(at: fileURL) // Mark as recently used for LRU eviction
		return UIImage(data: data)
	}

	func store(_ data: Data, for url: URL) {
		guard !data.isEmpty else {
			return
		}

		createDirectoryIfNeeded()

		let fileURL = fileURL(for: url)

		guard (try? fileSystem.write(data, to: fileURL)) != nil else {
			return
		}

		enforceMaxSize()
	}

	func remove(for url: URL) {
		let fileURL = fileURL(for: url)
		try? fileSystem.removeItem(at: fileURL)
	}

	func removeAll() {
		guard let files = try? fileSystem.contentsOfDirectory(at: configuration.directory) else {
			return
		}
		for file in files {
			try? fileSystem.removeItem(at: file)
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

	func createDirectoryIfNeeded() {
		guard !directoryCreated else {
			return
		}
		try? fileSystem.createDirectory(at: configuration.directory)
		directoryCreated = true
	}

	/// Removes least recently used files until total size is within `maxSize`.
	func enforceMaxSize() {
		guard let files = try? fileSystem.contentsOfDirectory(at: configuration.directory) else {
			return
		}

		var totalSize = 0
		var fileInfos: [(url: URL, size: Int, modified: Date)] = []

		for file in files {
			guard let attributes = try? fileSystem.fileAttributes(at: file) else {
				try? fileSystem.removeItem(at: file)
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
			try? fileSystem.removeItem(at: fileInfo.url)
			totalSize -= fileInfo.size
		}
	}
}
