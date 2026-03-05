import Testing

@testable import ChallengeHome

struct HomeEventTests {
    // MARK: - screenViewed

    @Test("Screen viewed event has correct name and empty properties")
    func screenViewedEvent() {
        // Given
        let sut = HomeEvent.screenViewed

        // Then
        #expect(sut.name == "home_viewed")
        #expect(sut.properties == [:])
    }

    // MARK: - characterButtonTapped

    @Test("Character button tapped event has correct name and empty properties")
    func characterButtonTappedEvent() {
        // Given
        let sut = HomeEvent.characterButtonTapped

        // Then
        #expect(sut.name == "home_character_button_tapped")
        #expect(sut.properties == [:])
    }

    // MARK: - infoButtonTapped

    @Test("Info button tapped event has correct name and empty properties")
    func infoButtonTappedEvent() {
        // Given
        let sut = HomeEvent.infoButtonTapped

        // Then
        #expect(sut.name == "home_info_button_tapped")
        #expect(sut.properties == [:])
    }
}
