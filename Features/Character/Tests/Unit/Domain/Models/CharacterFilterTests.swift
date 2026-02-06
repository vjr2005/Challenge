import Testing

@testable import ChallengeCharacter

struct CharacterFilterTests {
    // MARK: - isEmpty

    @Test("Empty filter returns true for isEmpty")
    func emptyFilterIsEmpty() {
        // Given
        let sut = CharacterFilter.empty

        // Then
        #expect(sut.isEmpty)
    }

    @Test("Filter with name only is not empty")
    func filterWithNameIsNotEmpty() {
        // Given
        let sut = CharacterFilter(name: "Rick")

        // Then
        #expect(!sut.isEmpty)
    }

    @Test("Filter with status only is not empty")
    func filterWithStatusIsNotEmpty() {
        // Given
        let sut = CharacterFilter(status: .alive)

        // Then
        #expect(!sut.isEmpty)
    }

    @Test("Filter with species only is not empty")
    func filterWithSpeciesIsNotEmpty() {
        // Given
        let sut = CharacterFilter(species: "Human")

        // Then
        #expect(!sut.isEmpty)
    }

    @Test("Filter with type only is not empty")
    func filterWithTypeIsNotEmpty() {
        // Given
        let sut = CharacterFilter(type: "Parasite")

        // Then
        #expect(!sut.isEmpty)
    }

    @Test("Filter with gender only is not empty")
    func filterWithGenderIsNotEmpty() {
        // Given
        let sut = CharacterFilter(gender: .male)

        // Then
        #expect(!sut.isEmpty)
    }

    // MARK: - activeFilterCount

    @Test("Empty filter has zero active filter count")
    func emptyFilterHasZeroActiveFilterCount() {
        // Given
        let sut = CharacterFilter.empty

        // Then
        #expect(sut.activeFilterCount == 0)
    }

    @Test("Filter with name only has zero active filter count")
    func filterWithNameOnlyHasZeroActiveFilterCount() {
        // Given
        let sut = CharacterFilter(name: "Rick")

        // Then
        #expect(sut.activeFilterCount == 0)
    }

    @Test("Filter with status has one active filter count")
    func filterWithStatusHasOneActiveFilterCount() {
        // Given
        let sut = CharacterFilter(status: .alive)

        // Then
        #expect(sut.activeFilterCount == 1)
    }

    @Test("Filter with all advanced fields has four active filter count")
    func filterWithAllAdvancedFieldsHasFourActiveFilterCount() {
        // Given
        let sut = CharacterFilter(
            status: .alive,
            species: "Human",
            type: "Parasite",
            gender: .male
        )

        // Then
        #expect(sut.activeFilterCount == 4)
    }

    @Test("Filter with all fields has four active filter count excluding name")
    func filterWithAllFieldsHasFourActiveFilterCountExcludingName() {
        // Given
        let sut = CharacterFilter(
            name: "Rick",
            status: .alive,
            species: "Human",
            type: "Parasite",
            gender: .male
        )

        // Then
        #expect(sut.activeFilterCount == 4)
    }

    // MARK: - Equatable

    @Test("Two empty filters are equal")
    func twoEmptyFiltersAreEqual() {
        // Given
        let filter1 = CharacterFilter.empty
        let filter2 = CharacterFilter.empty

        // Then
        #expect(filter1 == filter2)
    }

    @Test("Filters with same values are equal")
    func filtersWithSameValuesAreEqual() {
        // Given
        let filter1 = CharacterFilter(name: "Rick", status: .alive)
        let filter2 = CharacterFilter(name: "Rick", status: .alive)

        // Then
        #expect(filter1 == filter2)
    }

    @Test("Filters with different values are not equal")
    func filtersWithDifferentValuesAreNotEqual() {
        // Given
        let filter1 = CharacterFilter(name: "Rick", status: .alive)
        let filter2 = CharacterFilter(name: "Morty", status: .dead)

        // Then
        #expect(filter1 != filter2)
    }
}
