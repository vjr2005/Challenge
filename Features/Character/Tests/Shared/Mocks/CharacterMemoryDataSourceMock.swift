import Foundation

@testable import ChallengeCharacter

final class CharacterMemoryDataSourceMock: CharacterMemoryDataSourceContract, @unchecked Sendable {
    // MARK: - Configurable Returns

    var characterToReturn: CharacterDTO?
    var pageToReturn: CharactersResponseDTO?

    // MARK: - Call Tracking

    private(set) var getCharacterDetailCallCount = 0

    private(set) var saveCharacterDetailCallCount = 0
    private(set) var saveCharacterDetailLastValue: CharacterDTO?

    private(set) var getPageCallCount = 0

    private(set) var savePageCallCount = 0
    private(set) var savePageLastResponse: CharactersResponseDTO?
    private(set) var savePageLastPage: Int?

    // MARK: - CharacterMemoryDataSourceContract

    func getCharacterDetail(identifier: Int) -> CharacterDTO? {
        getCharacterDetailCallCount += 1
        return characterToReturn
    }

    func saveCharacterDetail(_ character: CharacterDTO) {
        saveCharacterDetailCallCount += 1
        saveCharacterDetailLastValue = character
    }

    func getPage(_ page: Int) -> CharactersResponseDTO? {
        getPageCallCount += 1
        return pageToReturn
    }

    func savePage(_ response: CharactersResponseDTO, page: Int) {
        savePageCallCount += 1
        savePageLastResponse = response
        savePageLastPage = page
    }
}
