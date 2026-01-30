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
}

private struct TestView: View {
    var body: some View {
        Text("Test")
    }
}
