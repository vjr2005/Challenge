import Testing

@testable import ChallengeCharacter

extension CharacterFilterViewModelTests {
    nonisolated struct DidTapResetScenario: Sendable, CustomTestStringConvertible {
        struct Given: Sendable {
            let filter: CharacterFilter
        }

        let testDescription: String
        let given: Given

        static let all: [Self] = [
            Self(
                testDescription: "With all filters set clears to empty",
                given: Given(filter: CharacterFilter(status: .alive, species: "Human", type: "Parasite", gender: .male))
            ),
            Self(
                testDescription: "With single filter set clears to empty",
                given: Given(filter: CharacterFilter(status: .alive))
            ),
            Self(
                testDescription: "With empty filter remains empty",
                given: Given(filter: .empty)
            )
        ]
    }
}
