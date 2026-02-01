import Testing

@testable import ChallengeCharacter

struct CharactersPageTests {
    @Test("Empty factory creates page with no characters and zero pagination values")
    func emptyFactoryCreatesCorrectPage() {
        // Given
        let page = 3

        // When
        let sut = CharactersPage.empty(currentPage: page)

        // Then
        let expected = CharactersPage(
            characters: [],
            currentPage: page,
            totalPages: 0,
            totalCount: 0,
            hasNextPage: false,
            hasPreviousPage: false
        )
        #expect(sut == expected)
    }
}
