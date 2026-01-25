import Foundation

@testable import ChallengeCharacter

final class CharacterMemoryDataSourceMock: CharacterMemoryDataSourceContract, @unchecked Sendable {
    // MARK: - Configurable Returns

    var characterToReturn: CharacterDTO?
    var pageToReturn: CharactersResponseDTO?

    // MARK: - Call Tracking

    private(set) var getCharacterCallCount = 0
    private(set) var getCharacterLastIdentifier: Int?

    private(set) var saveCharacterCallCount = 0
    private(set) var saveCharacterLastValue: CharacterDTO?

    private(set) var getPageCallCount = 0
    private(set) var getPageLastPage: Int?

    private(set) var savePageCallCount = 0
    private(set) var savePageLastResponse: CharactersResponseDTO?
    private(set) var savePageLastPage: Int?

    // MARK: - CharacterMemoryDataSourceContract

    func getCharacter(identifier: Int) -> CharacterDTO? {
        getCharacterCallCount += 1
        getCharacterLastIdentifier = identifier
        return characterToReturn
    }

    func saveCharacter(_ character: CharacterDTO) {
        saveCharacterCallCount += 1
        saveCharacterLastValue = character
    }

    func getPage(_ page: Int) -> CharactersResponseDTO? {
        getPageCallCount += 1
        getPageLastPage = page
        return pageToReturn
    }

    func savePage(_ response: CharactersResponseDTO, page: Int) {
        savePageCallCount += 1
        savePageLastResponse = response
        savePageLastPage = page
    }
}
