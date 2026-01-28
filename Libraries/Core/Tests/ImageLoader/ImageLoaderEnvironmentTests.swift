import SwiftUI
import Testing

@testable import ChallengeCore
@testable import ChallengeCoreMocks

struct ImageLoaderEnvironmentTests {
    @Test
    func defaultImageLoaderIsCachedImageLoader() {
        // Given
        let sut = EnvironmentValues()

        // When
        let loader = sut.imageLoader

        // Then
        #expect(loader is CachedImageLoader)
    }

    @Test
    func imageLoaderCanBeSetAndRetrieved() {
        // Given
        var sut = EnvironmentValues()
        let customLoader = ImageLoaderMock(image: nil)

        // When
        sut.imageLoader = customLoader

        // Then
        #expect(sut.imageLoader as? ImageLoaderMock === customLoader)
    }

    @Test
    func imageLoaderViewModifierReturnsModifiedView() {
        // Given
        let customLoader = ImageLoaderMock(image: nil)
        let baseView = Text("Test")

        // When
        let modifiedView = baseView.imageLoader(customLoader)

        // Then
        #expect(type(of: modifiedView) != type(of: baseView))
    }
}
