import Testing

@testable import ChallengeHome

struct HomeEventTests {
    // MARK: - screenViewed

    @Test("Screen viewed event has correct name")
    func screenViewedEventHasCorrectName() {
        // Given
        let sut = HomeEvent.screenViewed

        // Then
        #expect(sut.name == "home_viewed")
    }

    @Test("Screen viewed event has empty properties")
    func screenViewedEventHasEmptyProperties() {
        // Given
        let sut = HomeEvent.screenViewed

        // Then
        #expect(sut.properties == [:])
    }

    // MARK: - characterButtonTapped

    @Test("Character button tapped event has correct name")
    func characterButtonTappedEventHasCorrectName() {
        // Given
        let sut = HomeEvent.characterButtonTapped

        // Then
        #expect(sut.name == "home_character_button_tapped")
    }

    @Test("Character button tapped event has empty properties")
    func characterButtonTappedEventHasEmptyProperties() {
        // Given
        let sut = HomeEvent.characterButtonTapped

        // Then
        #expect(sut.properties == [:])
    }
}
