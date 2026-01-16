import ChallengeCoreMocks
import Foundation
import Testing

@testable import ChallengeCharacter

struct CharacterListViewModelTests {
	// MARK: - Initial State

	@Test
	func initialStateIsIdle() {
		// Given
		let useCase = GetCharactersUseCaseMock()
		let router = RouterMock()
		let sut = CharacterListViewModel(getCharactersUseCase: useCase, router: router)

		// Then
		#expect(sut.state == .idle)
	}

	// MARK: - Load

	@Test
	func loadSetsLoadedStateOnSuccess() async {
		// Given
		let expected = CharactersPage.stub()
		let useCase = GetCharactersUseCaseMock()
		useCase.result = .success(expected)
		let router = RouterMock()
		let sut = CharacterListViewModel(getCharactersUseCase: useCase, router: router)

		// When
		await sut.load()

		// Then
		#expect(sut.state == .loaded(expected))
	}

	@Test
	func loadSetsEmptyStateWhenNoCharacters() async {
		// Given
		let emptyPage = CharactersPage.stub(characters: [])
		let useCase = GetCharactersUseCaseMock()
		useCase.result = .success(emptyPage)
		let router = RouterMock()
		let sut = CharacterListViewModel(getCharactersUseCase: useCase, router: router)

		// When
		await sut.load()

		// Then
		#expect(sut.state == .empty)
	}

	@Test
	func loadSetsErrorStateOnFailure() async {
		// Given
		let useCase = GetCharactersUseCaseMock()
		useCase.result = .failure(TestError.network)
		let router = RouterMock()
		let sut = CharacterListViewModel(getCharactersUseCase: useCase, router: router)

		// When
		await sut.load()

		// Then
		#expect(sut.state == .error(TestError.network))
	}

	@Test
	func loadCallsUseCaseWithPageOne() async {
		// Given
		let useCase = GetCharactersUseCaseMock()
		useCase.result = .success(.stub())
		let router = RouterMock()
		let sut = CharacterListViewModel(getCharactersUseCase: useCase, router: router)

		// When
		await sut.load()

		// Then
		#expect(useCase.executeCallCount == 1)
		#expect(useCase.lastRequestedPage == 1)
	}

	// MARK: - Load More

	@Test
	func loadMoreAppendsCharactersToExistingPage() async {
		// Given
		let firstPageCharacters = [Character.stub(id: 1)]
		let secondPageCharacters = [Character.stub(id: 2)]
		let firstPage = CharactersPage.stub(characters: firstPageCharacters, currentPage: 1, hasNextPage: true)
		let secondPage = CharactersPage.stub(characters: secondPageCharacters, currentPage: 2, hasNextPage: false)

		let useCase = GetCharactersUseCaseMock()
		useCase.result = .success(firstPage)
		let router = RouterMock()
		let sut = CharacterListViewModel(getCharactersUseCase: useCase, router: router)

		await sut.load()
		useCase.result = .success(secondPage)

		// When
		await sut.loadMore()

		// Then
		let expected = CharactersPage.stub(
			characters: [Character.stub(id: 1), Character.stub(id: 2)],
			currentPage: 2,
			hasNextPage: false,
			hasPreviousPage: false
		)
		#expect(sut.state == .loaded(expected))
	}

	@Test
	func loadMoreIncrementsPage() async {
		// Given
		let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
		let useCase = GetCharactersUseCaseMock()
		useCase.result = .success(firstPage)
		let router = RouterMock()
		let sut = CharacterListViewModel(getCharactersUseCase: useCase, router: router)

		await sut.load()

		// When
		await sut.loadMore()

		// Then
		#expect(useCase.lastRequestedPage == 2)
	}

	@Test
	func loadMoreDoesNothingWhenNoNextPage() async {
		// Given
		let lastPage = CharactersPage.stub(hasNextPage: false)
		let useCase = GetCharactersUseCaseMock()
		useCase.result = .success(lastPage)
		let router = RouterMock()
		let sut = CharacterListViewModel(getCharactersUseCase: useCase, router: router)

		await sut.load()
		let callCountAfterLoad = useCase.executeCallCount

		// When
		await sut.loadMore()

		// Then
		#expect(useCase.executeCallCount == callCountAfterLoad)
	}

	// MARK: - Navigation

	@Test
	func didSelectNavigatesToCharacterDetail() {
		// Given
		let character = Character.stub(id: 42)
		let useCase = GetCharactersUseCaseMock()
		let router = RouterMock()
		let sut = CharacterListViewModel(getCharactersUseCase: useCase, router: router)

		// When
		sut.didSelect(character)

		// Then
		#expect(router.navigatedDestinations.count == 1)
		let destination = router.navigatedDestinations.first as? CharacterNavigation
		#expect(destination == .detail(identifier: 42))
	}
}

private enum TestError: Error {
	case network
}
