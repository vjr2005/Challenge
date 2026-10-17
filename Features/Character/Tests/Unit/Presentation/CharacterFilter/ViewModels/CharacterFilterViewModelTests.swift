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
