import ChallengeSnapshotTestKit
import SwiftUI
import Testing

@testable import ChallengeSystem

struct NotFoundViewSnapshotTests {
    init() {
        UIView.setAnimationsEnabled(false)
    }

    @Test("Renders not found view with default message")
    func defaultState() {
        // Given
        let viewModel = NotFoundViewModelStub()

        // When
        let view = NavigationStack {
            NotFoundView(viewModel: viewModel)
        }

        // Then
        assertSnapshot(of: view, as: .device)
    }
}
