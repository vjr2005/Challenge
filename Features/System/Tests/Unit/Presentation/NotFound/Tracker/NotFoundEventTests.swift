import Testing

@testable import ChallengeSystem

struct NotFoundEventTests {
    // MARK: - screenViewed

    @Test("Screen viewed event has correct name")
    func screenViewedEventHasCorrectName() {
        // Given
        let sut = NotFoundEvent.screenViewed

        // Then
        #expect(sut.name == "not_found_viewed")
    }

    @Test("Screen viewed event has empty properties")
    func screenViewedEventHasEmptyProperties() {
        // Given
        let sut = NotFoundEvent.screenViewed

        // Then
        #expect(sut.properties == [:])
    }

    // MARK: - goBackButtonTapped

    @Test("Go back button tapped event has correct name")
    func goBackButtonTappedEventHasCorrectName() {
        // Given
        let sut = NotFoundEvent.goBackButtonTapped

        // Then
        #expect(sut.name == "not_found_go_back_tapped")
    }

    @Test("Go back button tapped event has empty properties")
    func goBackButtonTappedEventHasEmptyProperties() {
        // Given
        let sut = NotFoundEvent.goBackButtonTapped

        // Then
        #expect(sut.properties == [:])
    }
}
