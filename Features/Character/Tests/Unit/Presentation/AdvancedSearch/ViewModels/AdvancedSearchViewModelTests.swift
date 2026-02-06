import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct AdvancedSearchViewModelTests {
    // MARK: - Properties

    private let filterState = CharacterFilterState()
    private let navigatorMock = AdvancedSearchNavigatorMock()
    private let trackerMock = AdvancedSearchTrackerMock()
    private let sut: AdvancedSearchViewModel

    // MARK: - Initialization

    init() {
        sut = AdvancedSearchViewModel(
            filterState: filterState,
            navigator: navigatorMock,
            tracker: trackerMock
        )
    }

    // MARK: - Initial State

    @Test("Initial state copies from empty filter state")
    func initialStateCopiesFromEmptyFilterState() {
        // Then
        #expect(sut.localFilterState.status == nil)
        #expect(sut.localFilterState.species == nil)
        #expect(sut.localFilterState.type == nil)
        #expect(sut.localFilterState.gender == nil)
        #expect(!sut.hasActiveFilters)
    }

    @Test("Initial state copies from populated filter state")
    func initialStateCopiesFromPopulatedFilterState() {
        // Given
        let populatedFilterState = CharacterFilterState()
        populatedFilterState.status = .alive
        populatedFilterState.species = "Human"
        populatedFilterState.type = "Parasite"
        populatedFilterState.gender = .male

        // When
        let viewModel = AdvancedSearchViewModel(
            filterState: populatedFilterState,
            navigator: navigatorMock,
            tracker: trackerMock
        )

        // Then
        #expect(viewModel.localFilterState.status == .alive)
        #expect(viewModel.localFilterState.species == "Human")
        #expect(viewModel.localFilterState.type == "Parasite")
        #expect(viewModel.localFilterState.gender == .male)
        #expect(viewModel.hasActiveFilters)
    }

    // MARK: - hasActiveFilters

    @Test("hasActiveFilters returns true when status is set")
    func hasActiveFiltersReturnsTrueWhenStatusIsSet() {
        // When
        sut.localFilterState.status = .alive

        // Then
        #expect(sut.hasActiveFilters)
    }

    @Test("hasActiveFilters returns true when species is set")
    func hasActiveFiltersReturnsTrueWhenSpeciesIsSet() {
        // When
        sut.localFilterState.species = "Human"

        // Then
        #expect(sut.hasActiveFilters)
    }

    @Test("hasActiveFilters returns true when type is set")
    func hasActiveFiltersReturnsTrueWhenTypeIsSet() {
        // When
        sut.localFilterState.type = "Parasite"

        // Then
        #expect(sut.hasActiveFilters)
    }

    @Test("hasActiveFilters returns true when gender is set")
    func hasActiveFiltersReturnsTrueWhenGenderIsSet() {
        // When
        sut.localFilterState.gender = .female

        // Then
        #expect(sut.hasActiveFilters)
    }

    @Test("hasActiveFilters returns false when all fields are empty")
    func hasActiveFiltersReturnsFalseWhenAllFieldsAreEmpty() {
        // Then
        #expect(!sut.hasActiveFilters)
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

    @Test("didTapApply commits local values to shared filter state")
    func didTapApplyCommitsToSharedFilterState() {
        // Given
        sut.localFilterState.status = .dead
        sut.localFilterState.species = "Alien"
        sut.localFilterState.type = "Robot"
        sut.localFilterState.gender = .genderless

        // When
        sut.didTapApply()

        // Then
        #expect(filterState.status == .dead)
        #expect(filterState.species == "Alien")
        #expect(filterState.type == "Robot")
        #expect(filterState.gender == .genderless)
    }

    @Test("didTapApply calls navigator dismiss")
    func didTapApplyCallsNavigatorDismiss() {
        // When
        sut.didTapApply()

        // Then
        #expect(navigatorMock.dismissCallCount == 1)
    }

    @Test("didTapApply tracks apply filters with correct count")
    func didTapApplyTracksApplyFilters() {
        // Given
        sut.localFilterState.status = .alive
        sut.localFilterState.gender = .male

        // When
        sut.didTapApply()

        // Then
        #expect(trackerMock.applyFiltersCallCount == 1)
        #expect(trackerMock.lastAppliedFilterCount == 2)
    }

    // MARK: - didTapReset

    @Test("didTapReset clears all local values")
    func didTapResetClearsAllLocalValues() {
        // Given
        sut.localFilterState.status = .alive
        sut.localFilterState.species = "Human"
        sut.localFilterState.type = "Parasite"
        sut.localFilterState.gender = .male

        // When
        sut.didTapReset()

        // Then
        #expect(sut.localFilterState.status == nil)
        #expect(sut.localFilterState.species == nil)
        #expect(sut.localFilterState.type == nil)
        #expect(sut.localFilterState.gender == nil)
    }

    @Test("didTapReset does not commit to shared filter state")
    func didTapResetDoesNotCommitToSharedFilterState() {
        // Given
        filterState.status = .alive
        filterState.species = "Human"

        let viewModel = AdvancedSearchViewModel(
            filterState: filterState,
            navigator: navigatorMock,
            tracker: trackerMock
        )
        viewModel.localFilterState.status = .dead
        viewModel.localFilterState.species = "Alien"

        // When
        viewModel.didTapReset()

        // Then - shared state still has original values
        #expect(filterState.status == .alive)
        #expect(filterState.species == "Human")
    }

    @Test("didTapReset tracks reset filters")
    func didTapResetTracksResetFilters() {
        // When
        sut.didTapReset()

        // Then
        #expect(trackerMock.resetFiltersCallCount == 1)
    }

    // MARK: - didTapClose

    @Test("didTapClose calls navigator dismiss")
    func didTapCloseCallsNavigatorDismiss() {
        // When
        sut.didTapClose()

        // Then
        #expect(navigatorMock.dismissCallCount == 1)
    }

    @Test("didTapClose tracks close tapped")
    func didTapCloseTracksCloseTapped() {
        // When
        sut.didTapClose()

        // Then
        #expect(trackerMock.closeTappedCallCount == 1)
    }

    @Test("didTapClose does not commit to shared filter state")
    func didTapCloseDoesNotCommitToSharedFilterState() {
        // Given
        sut.localFilterState.status = .dead
        sut.localFilterState.species = "Alien"

        // When
        sut.didTapClose()

        // Then - shared state remains empty
        #expect(filterState.status == nil)
        #expect(filterState.species == nil)
    }
}
