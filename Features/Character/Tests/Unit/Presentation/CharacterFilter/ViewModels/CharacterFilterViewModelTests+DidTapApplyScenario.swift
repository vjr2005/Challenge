import Testing

@testable import ChallengeCharacter

extension CharacterFilterViewModelTests {
    nonisolated struct DidTapApplyScenario: Sendable, CustomTestStringConvertible {
        struct Given: Sendable {
            let filter: CharacterFilter
        }

        struct Expected: Sendable {
            let appliedFilter: CharacterFilter
            let filterCount: Int
        }

        let testDescription: String
        let given: Given
        let expected: Expected

        static let all: [Self] = [
            Self(
                testDescription: "With all filters applies full filter and tracks count 4",
                given: Given(filter: CharacterFilter(status: .dead, species: "Alien", type: "Robot", gender: .genderless)),
                expected: Expected(
                    appliedFilter: CharacterFilter(status: .dead, species: "Alien", type: "Robot", gender: .genderless),
                    filterCount: 4
                )
            ),
            Self(
                testDescription: "With partial filters applies partial filter and tracks count 2",
                given: Given(filter: CharacterFilter(status: .alive, gender: .male)),
                expected: Expected(
                    appliedFilter: CharacterFilter(status: .alive, gender: .male),
                    filterCount: 2
                )
            ),
            Self(
                testDescription: "With empty filter applies empty filter and tracks count 0",
                given: Given(filter: .empty),
                expected: Expected(
                    appliedFilter: .empty,
                    filterCount: 0
                )
            )
        ]
    }
}
