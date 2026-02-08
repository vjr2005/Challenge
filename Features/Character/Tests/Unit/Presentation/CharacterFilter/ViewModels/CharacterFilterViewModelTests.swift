import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
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

    @Test("hasActiveFilters returns true when status is set")
    func hasActiveFiltersReturnsTrueWhenStatusIsSet() {
        // When
        sut.filter.status = .alive

        // Then
        #expect(sut.hasActiveFilters)
    }

    @Test("hasActiveFilters returns true when species is set")
    func hasActiveFiltersReturnsTrueWhenSpeciesIsSet() {
        // When
        sut.filter.species = "Human"

        // Then
        #expect(sut.hasActiveFilters)
    }

    @Test("hasActiveFilters returns true when type is set")
    func hasActiveFiltersReturnsTrueWhenTypeIsSet() {
        // When
        sut.filter.type = "Parasite"

        // Then
        #expect(sut.hasActiveFilters)
    }

    @Test("hasActiveFilters returns true when gender is set")
    func hasActiveFiltersReturnsTrueWhenGenderIsSet() {
        // When
        sut.filter.gender = .female

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

    @Test("didTapApply calls delegate didApplyFilter with correct filter")
    func didTapApplyCallsDelegateDidApplyFilter() {
        // Given
        sut.filter.status = .dead
        sut.filter.species = "Alien"
        sut.filter.type = "Robot"
        sut.filter.gender = .genderless

        // When
        sut.didTapApply()

        // Then
        let expected = CharacterFilter(
            status: .dead,
            species: "Alien",
            type: "Robot",
            gender: .genderless
        )
        #expect(delegateMock.didApplyFilterCallCount == 1)
        #expect(delegateMock.lastAppliedFilter == expected)
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
        sut.filter.status = .alive
        sut.filter.gender = .male

        // When
        sut.didTapApply()

        // Then
        #expect(trackerMock.applyFiltersCallCount == 1)
        #expect(trackerMock.lastAppliedFilterCount == 2)
    }

    // MARK: - didTapReset

    @Test("didTapReset clears all filter values")
    func didTapResetClearsAllFilterValues() {
        // Given
        sut.filter.status = .alive
        sut.filter.species = "Human"
        sut.filter.type = "Parasite"
        sut.filter.gender = .male

        // When
        sut.didTapReset()

        // Then
        #expect(sut.filter == .empty)
    }

    @Test("didTapReset does not call delegate didApplyFilter")
    func didTapResetDoesNotCallDelegateDidApplyFilter() {
        // Given
        let delegateMock = CharacterFilterDelegateMock()
        delegateMock.currentFilter = CharacterFilter(status: .alive)
        let viewModel = CharacterFilterViewModel(
            delegate: delegateMock,
            navigator: navigatorMock,
            tracker: trackerMock
        )

        // When
        viewModel.didTapReset()

        // Then
        #expect(delegateMock.didApplyFilterCallCount == 0)
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

    @Test("didTapClose does not call delegate didApplyFilter")
    func didTapCloseDoesNotCallDelegateDidApplyFilter() {
        // Given
        sut.filter.status = .dead

        // When
        sut.didTapClose()

        // Then
        #expect(delegateMock.didApplyFilterCallCount == 0)
    }
}
