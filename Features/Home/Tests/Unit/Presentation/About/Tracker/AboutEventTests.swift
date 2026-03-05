import Testing

@testable import ChallengeHome

struct AboutEventTests {
    // MARK: - screenViewed

    @Test("Screen viewed event has correct name and empty properties")
    func screenViewedEvent() {
        // Given
        let sut = AboutEvent.screenViewed

        // Then
        #expect(sut.name == "about_viewed")
        #expect(sut.properties == [:])
    }
}
