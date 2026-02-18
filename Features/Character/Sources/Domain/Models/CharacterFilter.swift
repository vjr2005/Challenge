import Foundation

nonisolated public struct CharacterFilter: Equatable, Sendable {
    var name: String?
    var status: CharacterStatus?
    var species: String?
    var type: String?
    var gender: CharacterGender?

    init(
        name: String? = nil,
        status: CharacterStatus? = nil,
        species: String? = nil,
        type: String? = nil,
        gender: CharacterGender? = nil
    ) {
        self.name = name
        self.status = status
        self.species = species
        self.type = type
        self.gender = gender
    }

    var isEmpty: Bool {
        name == nil && status == nil && species == nil && type == nil && gender == nil
    }

    var activeFilterCount: Int {
        var count = 0
        if status != nil { count += 1 }
        if species != nil { count += 1 }
        if type != nil { count += 1 }
        if gender != nil { count += 1 }
        return count
    }

    static let empty = CharacterFilter()
}
