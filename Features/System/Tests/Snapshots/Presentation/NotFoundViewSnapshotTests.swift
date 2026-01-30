import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeSystem

struct NotFoundViewSnapshotTests {
    init() {
        UIView.setAnimationsEnabled(false)
    }

    @Test
    func defaultState() {
        // Given
        let viewModel = NotFoundViewModelStub()

        // When
        let view = NotFoundView(viewModel: viewModel)

        // Then
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
    }
}
