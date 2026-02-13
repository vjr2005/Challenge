import Testing
import UIKit

@testable import ChallengeCore

struct ImageMemoryCacheTests {
	private let image = UIImage(systemName: "star")

	// MARK: - Image Retrieval

	@Test("Returns nil when URL is not cached")
	func returnsNilWhenURLIsNotCached() throws {
		// Given
		let url = try #require(URL(string: "https://example.com/image.png"))
		let sut = ImageMemoryCache()

		// When
		let result = sut.image(for: url)

		// Then
		#expect(result == nil)
	}

	@Test("Returns image after storing it")
	func returnsImageAfterStoringIt() throws {
		// Given
		let url = try #require(URL(string: "https://example.com/image.png"))
		let image = try #require(image)
		let sut = ImageMemoryCache()
		sut.setImage(image, for: url)

		// When
		let result = sut.image(for: url)

		// Then
		#expect(result != nil)
	}

	@Test("Returns nil for different URL")
	func returnsNilForDifferentURL() throws {
		// Given
		let storedURL = try #require(URL(string: "https://example.com/image1.png"))
		let otherURL = try #require(URL(string: "https://example.com/image2.png"))
		let image = try #require(image)
		let sut = ImageMemoryCache()
		sut.setImage(image, for: storedURL)

		// When
		let result = sut.image(for: otherURL)

		// Then
		#expect(result == nil)
	}

	// MARK: - Remove

	@Test("Remove deletes cached image for URL")
	func removeDeletesCachedImageForURL() throws {
		// Given
		let url = try #require(URL(string: "https://example.com/image.png"))
		let image = try #require(image)
		let sut = ImageMemoryCache()
		sut.setImage(image, for: url)

		// When
		sut.removeCachedImage(for: url)

		// Then
		#expect(sut.image(for: url) == nil)
	}

	// MARK: - Remove All

	@Test("Remove all clears all cached images")
	func removeAllClearsAllCachedImages() throws {
		// Given
		let url1 = try #require(URL(string: "https://example.com/image1.png"))
		let url2 = try #require(URL(string: "https://example.com/image2.png"))
		let image = try #require(image)
		let sut = ImageMemoryCache()
		sut.setImage(image, for: url1)
		sut.setImage(image, for: url2)

		// When
		sut.removeAll()

		// Then
		#expect(sut.image(for: url1) == nil)
		#expect(sut.image(for: url2) == nil)
	}
}
