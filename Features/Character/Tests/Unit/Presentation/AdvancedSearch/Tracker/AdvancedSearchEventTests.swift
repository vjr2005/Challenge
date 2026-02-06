import Testing

@testable import ChallengeCharacter

struct AdvancedSearchEventTests {
    // MARK: - screenViewed

    @Test("Screen viewed event has correct name")
    func screenViewedEventHasCorrectName() {
        // Given
        let sut = AdvancedSearchEvent.screenViewed

        // Then
        #expect(sut.name == "advanced_search_viewed")
    }

    @Test("Screen viewed event has empty properties")
    func screenViewedEventHasEmptyProperties() {
        // Given
        let sut = AdvancedSearchEvent.screenViewed

        // Then
        #expect(sut.properties == [:])
    }

    // MARK: - filtersApplied

    @Test("Filters applied event has correct name")
    func filtersAppliedEventHasCorrectName() {
        // Given
        let sut = AdvancedSearchEvent.filtersApplied(filterCount: 3)

        // Then
        #expect(sut.name == "advanced_search_filters_applied")
    }

    @Test("Filters applied event has filter count in properties")
    func filtersAppliedEventHasFilterCountInProperties() {
        // Given
        let sut = AdvancedSearchEvent.filtersApplied(filterCount: 3)

        // Then
        #expect(sut.properties == ["filter_count": "3"])
    }

    // MARK: - filtersReset

    @Test("Filters reset event has correct name")
    func filtersResetEventHasCorrectName() {
        // Given
        let sut = AdvancedSearchEvent.filtersReset

        // Then
        #expect(sut.name == "advanced_search_filters_reset")
    }

    @Test("Filters reset event has empty properties")
    func filtersResetEventHasEmptyProperties() {
        // Given
        let sut = AdvancedSearchEvent.filtersReset

        // Then
        #expect(sut.properties == [:])
    }

    // MARK: - closeTapped

    @Test("Close tapped event has correct name")
    func closeTappedEventHasCorrectName() {
        // Given
        let sut = AdvancedSearchEvent.closeTapped

        // Then
        #expect(sut.name == "advanced_search_close_tapped")
    }

    @Test("Close tapped event has empty properties")
    func closeTappedEventHasEmptyProperties() {
        // Given
        let sut = AdvancedSearchEvent.closeTapped

        // Then
        #expect(sut.properties == [:])
    }
}
