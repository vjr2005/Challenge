import Testing

@testable import ChallengeCharacter

extension CharacterFilterViewModelTests {
    nonisolated struct HasActiveFiltersScenario: Sendable, CustomTestStringConvertible {
        struct Given: Sendable {
            let filter: CharacterFilter
        }

        struct Expected: Sendable {
            let hasActiveFilters: Bool
        }

        let testDescription: String
        let given: Given
        let expected: Expected

        static let all: [Self] = [
            Self(
                testDescription: "Returns true when status is set",
                given: Given(filter: CharacterFilter(status: .alive)),
                expected: Expected(hasActiveFilters: true)
            ),
            Self(
                testDescription: "Returns true when species is set",
                given: Given(filter: CharacterFilter(species: "Human")),
                expected: Expected(hasActiveFilters: true)
            ),
            Self(
                testDescription: "Returns true when type is set",
                given: Given(filter: CharacterFilter(type: "Parasite")),
                expected: Expected(hasActiveFilters: true)
            ),
            Self(
                testDescription: "Returns true when gender is set",
                given: Given(filter: CharacterFilter(gender: .female)),
                expected: Expected(hasActiveFilters: true)
            ),
            Self(
                testDescription: "Returns false when all fields are empty",
                given: Given(filter: .empty),
                expected: Expected(hasActiveFilters: false)
            )
        ]
    }
}
