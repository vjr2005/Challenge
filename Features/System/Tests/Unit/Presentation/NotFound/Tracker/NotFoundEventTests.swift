import Testing

@testable import ChallengeSystem

struct NotFoundEventTests {
    // MARK: - screenViewed

    @Test("Screen viewed event has correct name and empty properties")
    func screenViewedEvent() {
        // Given
        let sut = NotFoundEvent.screenViewed

        // Then
        #expect(sut.name == "not_found_viewed")
        #expect(sut.properties == [:])
    }

    // MARK: - goBackButtonTapped

    @Test("Go back button tapped event has correct name and empty properties")
    func goBackButtonTappedEvent() {
        // Given
        let sut = NotFoundEvent.goBackButtonTapped

        // Then
        #expect(sut.name == "not_found_go_back_tapped")
        #expect(sut.properties == [:])
    }
}
