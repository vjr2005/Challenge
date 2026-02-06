import Foundation

@Observable
final class CharacterFilterState {
    var status: CharacterStatus?
    var species: String?
    var type: String?
    var gender: CharacterGender?

    init() {}

    var filter: CharacterFilter {
        CharacterFilter(
            status: status,
            species: species,
            type: type,
            gender: gender
        )
    }

    func apply(from other: CharacterFilterState) {
        status = other.status
        species = other.species
        type = other.type
        gender = other.gender
    }

    func reset() {
        status = nil
        species = nil
        type = nil
        gender = nil
    }
}
