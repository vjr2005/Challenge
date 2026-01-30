import ChallengeCore
import SwiftUI
import Testing

@testable import ChallengeSystem

struct SystemFeatureTests {
    @Test
    func applyNavigationDestinationReturnsAnyView() {
        // Given
        let sut = SystemFeature()
        let navigatorMock = NavigatorMock()
        let testView = TestView()

        // When
        let result = sut.applyNavigationDestination(to: testView, navigator: navigatorMock)

        // Then
        #expect(result != nil)
    }

    // MARK: - View Factory

    @Test
    func viewForUnknownNavigationReturnsNotFoundView() {
        // Given
        let sut = SystemFeature()
        let navigatorMock = NavigatorMock()

        // When
        let result = sut.view(for: .notFound, navigator: navigatorMock)

        // Then
        let viewName = String(describing: type(of: result))
        #expect(viewName.contains("NotFoundView"))
    }
}

private struct TestView: View {
    var body: some View {
        Text("Test")
    }
}
