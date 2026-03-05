import Testing

@testable import ChallengeCharacter

struct CharacterFilterViewModelTests {
    // MARK: - Properties

    private let delegateMock = CharacterFilterDelegateMock()
    private let navigatorMock = CharacterFilterNavigatorMock()
    private let trackerMock = CharacterFilterTrackerMock()
    private let sut: CharacterFilterViewModel

    // MARK: - Initialization

    init() {
        sut = CharacterFilterViewModel(
            delegate: delegateMock,
            navigator: navigatorMock,
            tracker: trackerMock
        )
    }

    // MARK: - Initial State

    @Test("Initial state has empty filter when delegate has empty filter")
    func initialStateHasEmptyFilter() {
        // Then
        #expect(sut.filter == .empty)
        #expect(!sut.hasActiveFilters)
    }

    @Test("Initial state copies from delegate current filter")
    func initialStateCopiesFromDelegateCurrentFilter() {
        // Given
        let delegateMock = CharacterFilterDelegateMock()
        delegateMock.currentFilter = CharacterFilter(
            status: .alive,
            species: "Human",
            type: "Parasite",
            gender: .male
        )

        // When
        let viewModel = CharacterFilterViewModel(
            delegate: delegateMock,
            navigator: navigatorMock,
            tracker: trackerMock
        )

        // Then
        #expect(viewModel.filter.status == .alive)
        #expect(viewModel.filter.species == "Human")
        #expect(viewModel.filter.type == "Parasite")
        #expect(viewModel.filter.gender == .male)
        #expect(viewModel.hasActiveFilters)
    }

    // MARK: - hasActiveFilters

    @Test("hasActiveFilters produces expected result per scenario", arguments: HasActiveFiltersScenario.all)
    func hasActiveFilters(scenario: HasActiveFiltersScenario) {
        // Given
        sut.filter = scenario.given.filter

        // Then
        #expect(sut.hasActiveFilters == scenario.expected.hasActiveFilters)
    }

    // MARK: - didAppear

    @Test("didAppear tracks screen viewed")
    func didAppearTracksScreenViewed() {
        // When
        sut.didAppear()

        // Then
        #expect(trackerMock.screenViewedCallCount == 1)
    }

    // MARK: - didTapApply

    @Test("didTapApply produces expected outcome per scenario", arguments: DidTapApplyScenario.all)
    func didTapApply(scenario: DidTapApplyScenario) {
        // Given
        sut.filter = scenario.given.filter

        // When
        sut.didTapApply()

        // Then
        #expect(delegateMock.didApplyFilterCallCount == 1)
        #expect(navigatorMock.dismissCallCount == 1)
        #expect(trackerMock.applyFiltersCallCount == 1)
        #expect(delegateMock.lastAppliedFilter == scenario.expected.appliedFilter)
        #expect(trackerMock.lastAppliedFilterCount == scenario.expected.filterCount)
    }

    // MARK: - didTapReset

    @Test("didTapReset produces expected outcome per scenario", arguments: DidTapResetScenario.all)
    func didTapReset(scenario: DidTapResetScenario) {
        // Given
        sut.filter = scenario.given.filter

        // When
        sut.didTapReset()

        // Then
        #expect(sut.filter == .empty)
        #expect(trackerMock.resetFiltersCallCount == 1)
        #expect(delegateMock.didApplyFilterCallCount == 0)
    }

    // MARK: - didTapClose

    @Test("didTapClose dismisses and tracks without applying filter")
    func didTapCloseDismissesAndTracksWithoutApplyingFilter() {
        // Given
        sut.filter.status = .dead

        // When
        sut.didTapClose()

        // Then
        #expect(navigatorMock.dismissCallCount == 1)
        #expect(trackerMock.closeTappedCallCount == 1)
        #expect(delegateMock.didApplyFilterCallCount == 0)
    }
}

// MARK: - Test Helpers

extension CharacterFilterViewModelTests {
    nonisolated struct DidTapResetScenario: Sendable, CustomTestStringConvertible {
        struct Given: Sendable {
            let filter: CharacterFilter
        }

        let testDescription: String
        let given: Given

        static let all: [DidTapResetScenario] = [
            DidTapResetScenario(
                testDescription: "With all filters set clears to empty",
                given: Given(filter: CharacterFilter(status: .alive, species: "Human", type: "Parasite", gender: .male))
            ),
            DidTapResetScenario(
                testDescription: "With single filter set clears to empty",
                given: Given(filter: CharacterFilter(status: .alive))
            ),
            DidTapResetScenario(
                testDescription: "With empty filter remains empty",
                given: Given(filter: .empty)
            ),
        ]
    }

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

        static let all: [DidTapApplyScenario] = [
            DidTapApplyScenario(
                testDescription: "With all filters applies full filter and tracks count 4",
                given: Given(filter: CharacterFilter(status: .dead, species: "Alien", type: "Robot", gender: .genderless)),
                expected: Expected(
                    appliedFilter: CharacterFilter(status: .dead, species: "Alien", type: "Robot", gender: .genderless),
                    filterCount: 4
                )
            ),
            DidTapApplyScenario(
                testDescription: "With partial filters applies partial filter and tracks count 2",
                given: Given(filter: CharacterFilter(status: .alive, gender: .male)),
                expected: Expected(
                    appliedFilter: CharacterFilter(status: .alive, gender: .male),
                    filterCount: 2
                )
            ),
            DidTapApplyScenario(
                testDescription: "With empty filter applies empty filter and tracks count 0",
                given: Given(filter: .empty),
                expected: Expected(
                    appliedFilter: .empty,
                    filterCount: 0
                )
            ),
        ]
    }

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

        static let all: [HasActiveFiltersScenario] = [
            HasActiveFiltersScenario(
                testDescription: "Returns true when status is set",
                given: Given(filter: CharacterFilter(status: .alive)),
                expected: Expected(hasActiveFilters: true)
            ),
            HasActiveFiltersScenario(
                testDescription: "Returns true when species is set",
                given: Given(filter: CharacterFilter(species: "Human")),
                expected: Expected(hasActiveFilters: true)
            ),
            HasActiveFiltersScenario(
                testDescription: "Returns true when type is set",
                given: Given(filter: CharacterFilter(type: "Parasite")),
                expected: Expected(hasActiveFilters: true)
            ),
            HasActiveFiltersScenario(
                testDescription: "Returns true when gender is set",
                given: Given(filter: CharacterFilter(gender: .female)),
                expected: Expected(hasActiveFilters: true)
            ),
            HasActiveFiltersScenario(
                testDescription: "Returns false when all fields are empty",
                given: Given(filter: .empty),
                expected: Expected(hasActiveFilters: false)
            ),
        ]
    }
}
