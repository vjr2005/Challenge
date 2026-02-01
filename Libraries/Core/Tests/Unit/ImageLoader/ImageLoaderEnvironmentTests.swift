import SwiftUI
import Testing

@testable import ChallengeCore
@testable import ChallengeCoreMocks

struct ImageLoaderEnvironmentTests {
    @Test("Default image loader is CachedImageLoader")
    func defaultImageLoaderIsCachedImageLoader() {
        // Given
        let sut = EnvironmentValues()

        // When
        let loader = sut.imageLoader

        // Then
        #expect(loader is CachedImageLoader)
    }

    @Test("Image loader can be set and retrieved from environment")
    func imageLoaderCanBeSetAndRetrieved() {
        // Given
        var sut = EnvironmentValues()
        let customLoader = ImageLoaderMock(cachedImage: nil, asyncImage: nil)

        // When
        sut.imageLoader = customLoader

        // Then
        #expect(sut.imageLoader as? ImageLoaderMock === customLoader)
    }

    @Test("Image loader view modifier returns modified view")
    func imageLoaderViewModifierReturnsModifiedView() {
        // Given
        let customLoader = ImageLoaderMock(cachedImage: nil, asyncImage: nil)
        let baseView = Text("Test")

        // When
        let modifiedView = baseView.imageLoader(customLoader)

        // Then
        #expect(type(of: modifiedView) != type(of: baseView))
    }
}
