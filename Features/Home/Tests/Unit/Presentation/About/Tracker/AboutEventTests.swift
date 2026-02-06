import Testing

@testable import ChallengeHome

struct AboutEventTests {
    // MARK: - screenViewed

    @Test("Screen viewed event has correct name")
    func screenViewedEventHasCorrectName() {
        // Given
        let sut = AboutEvent.screenViewed

        // Then
        #expect(sut.name == "about_viewed")
    }

    @Test("Screen viewed event has empty properties")
    func screenViewedEventHasEmptyProperties() {
        // Given
        let sut = AboutEvent.screenViewed

        // Then
        #expect(sut.properties == [:])
    }
}
