import Foundation

@testable import ChallengeCharacter

actor CharacterMemoryDataSourceMock: CharacterLocalDataSourceContract {
    // MARK: - Configurable Returns

    private(set) var characterToReturn: CharacterDTO?
    private(set) var pageToReturn: CharactersResponseDTO?

    func setPageToReturn(_ page: CharactersResponseDTO?) {
        pageToReturn = page
    }

    // MARK: - Call Tracking

    private(set) var getCharacterCallCount = 0

    private(set) var saveCharacterCallCount = 0
    private(set) var saveCharacterLastValue: CharacterDTO?

    private(set) var savePageCallCount = 0
    private(set) var savePageLastResponse: CharactersResponseDTO?
    private(set) var savePageLastPage: Int?

    private(set) var clearPagesCallCount = 0

    // MARK: - CharacterLocalDataSourceContract

    func getCharacter(identifier: Int) -> CharacterDTO? {
        getCharacterCallCount += 1
        return characterToReturn
    }

    func saveCharacter(_ character: CharacterDTO) {
        saveCharacterCallCount += 1
        saveCharacterLastValue = character
    }

    func getPage(_ page: Int) -> CharactersResponseDTO? {
        return pageToReturn
    }

    func savePage(_ response: CharactersResponseDTO, page: Int) {
        savePageCallCount += 1
        savePageLastResponse = response
        savePageLastPage = page
    }

    func clearPages() {
        clearPagesCallCount += 1
    }
}
