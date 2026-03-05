import Testing

@testable import ChallengeCharacter

struct CharacterFilterEventTests {
    // MARK: - screenViewed

    @Test("Screen viewed event has correct name and empty properties")
    func screenViewedEvent() {
        // Given
        let sut = CharacterFilterEvent.screenViewed

        // Then
        #expect(sut.name == "character_filter_viewed")
        #expect(sut.properties == [:])
    }

    // MARK: - filtersApplied

    @Test("Filters applied event has correct name and properties")
    func filtersAppliedEvent() {
        // Given
        let sut = CharacterFilterEvent.filtersApplied(filterCount: 3)

        // Then
        #expect(sut.name == "character_filter_filters_applied")
        #expect(sut.properties == ["filter_count": "3"])
    }

    // MARK: - filtersReset

    @Test("Filters reset event has correct name and empty properties")
    func filtersResetEvent() {
        // Given
        let sut = CharacterFilterEvent.filtersReset

        // Then
        #expect(sut.name == "character_filter_filters_reset")
        #expect(sut.properties == [:])
    }

    // MARK: - closeTapped

    @Test("Close tapped event has correct name and empty properties")
    func closeTappedEvent() {
        // Given
        let sut = CharacterFilterEvent.closeTapped

        // Then
        #expect(sut.name == "character_filter_close_tapped")
        #expect(sut.properties == [:])
    }
}
