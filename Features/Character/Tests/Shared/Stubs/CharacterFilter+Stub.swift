import Foundation

@testable import ChallengeCharacter

extension CharacterFilter {
    static func stub(
        name: String? = nil,
        status: CharacterStatus? = nil,
        species: String? = nil,
        type: String? = nil,
        gender: CharacterGender? = nil
    ) -> CharacterFilter {
        CharacterFilter(
            name: name,
            status: status,
            species: species,
            type: type,
            gender: gender
        )
    }
}
