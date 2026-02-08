import Testing

@testable import ChallengeCharacter

struct CharacterFilterEventTests {
    // MARK: - screenViewed

    @Test("Screen viewed event has correct name")
    func screenViewedEventHasCorrectName() {
        // Given
        let sut = CharacterFilterEvent.screenViewed

        // Then
        #expect(sut.name == "character_filter_viewed")
    }

    @Test("Screen viewed event has empty properties")
    func screenViewedEventHasEmptyProperties() {
        // Given
        let sut = CharacterFilterEvent.screenViewed

        // Then
        #expect(sut.properties == [:])
    }

    // MARK: - filtersApplied

    @Test("Filters applied event has correct name")
    func filtersAppliedEventHasCorrectName() {
        // Given
        let sut = CharacterFilterEvent.filtersApplied(filterCount: 3)

        // Then
        #expect(sut.name == "character_filter_filters_applied")
    }

    @Test("Filters applied event has filter count in properties")
    func filtersAppliedEventHasFilterCountInProperties() {
        // Given
        let sut = CharacterFilterEvent.filtersApplied(filterCount: 3)

        // Then
        #expect(sut.properties == ["filter_count": "3"])
    }

    // MARK: - filtersReset

    @Test("Filters reset event has correct name")
    func filtersResetEventHasCorrectName() {
        // Given
        let sut = CharacterFilterEvent.filtersReset

        // Then
        #expect(sut.name == "character_filter_filters_reset")
    }

    @Test("Filters reset event has empty properties")
    func filtersResetEventHasEmptyProperties() {
        // Given
        let sut = CharacterFilterEvent.filtersReset

        // Then
        #expect(sut.properties == [:])
    }

    // MARK: - closeTapped

    @Test("Close tapped event has correct name")
    func closeTappedEventHasCorrectName() {
        // Given
        let sut = CharacterFilterEvent.closeTapped

        // Then
        #expect(sut.name == "character_filter_close_tapped")
    }

    @Test("Close tapped event has empty properties")
    func closeTappedEventHasEmptyProperties() {
        // Given
        let sut = CharacterFilterEvent.closeTapped

        // Then
        #expect(sut.properties == [:])
    }
}
