import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Foundation
import Testing

@testable import ChallengeCharacter

struct CharacterContainerTests {
	private let testBundle = Bundle(for: BundleToken.self)

	// MARK: - CharacterListViewModel

	@Test
	func makeCharacterListViewModelReturnsConfiguredInstance() {
		// Given
		let httpClient = HTTPClientMock()
		let router = RouterMock()
		let sut = CharacterContainer(httpClient: httpClient)

		// When
		let viewModel = sut.makeCharacterListViewModel(router: router)

		// Then
		#expect(viewModel.state == .idle)
	}

	@Test
	func makeCharacterListViewModelUsesInjectedHTTPClient() async throws {
		// Given
		let jsonData = try testBundle.loadJSONData("characters_response")
		let httpClient = HTTPClientMock(result: .success(jsonData))
		let router = RouterMock()
		let sut = CharacterContainer(httpClient: httpClient)
		let viewModel = sut.makeCharacterListViewModel(router: router)

		// When
		await viewModel.load()

		// Then
		#expect(httpClient.requestedEndpoints.count == 1)
	}

	// MARK: - CharacterDetailViewModel

	@Test
	func makeCharacterDetailViewModelReturnsConfiguredInstance() {
		// Given
		let httpClient = HTTPClientMock()
		let router = RouterMock()
		let sut = CharacterContainer(httpClient: httpClient)

		// When
		let viewModel = sut.makeCharacterDetailViewModel(identifier: 1, router: router)

		// Then
		#expect(viewModel.state == .idle)
	}

	@Test
	func makeCharacterDetailViewModelUsesInjectedHTTPClient() async throws {
		// Given
		let jsonData = try testBundle.loadJSONData("character")
		let httpClient = HTTPClientMock(result: .success(jsonData))
		let router = RouterMock()
		let sut = CharacterContainer(httpClient: httpClient)
		let viewModel = sut.makeCharacterDetailViewModel(identifier: 1, router: router)

		// When
		await viewModel.load()

		// Then
		#expect(httpClient.requestedEndpoints.count == 1)
	}

	// MARK: - Shared Repository

	@Test
	func multipleDetailViewModelsShareSameRepository() async throws {
		// Given
		let jsonData = try testBundle.loadJSONData("character")
		let httpClient = HTTPClientMock(result: .success(jsonData))
		let router = RouterMock()
		let sut = CharacterContainer(httpClient: httpClient)

		// When
		let viewModel1 = sut.makeCharacterDetailViewModel(identifier: 1, router: router)
		let viewModel2 = sut.makeCharacterDetailViewModel(identifier: 1, router: router)

		await viewModel1.load()
		await viewModel2.load()

		// Then - Second load uses cached data from shared repository
		#expect(httpClient.requestedEndpoints.count == 1)
	}

	@Test
	func listAndDetailViewModelsShareSameRepository() async throws {
		// Given
		let jsonData = try testBundle.loadJSONData("characters_response")
		let httpClient = HTTPClientMock(result: .success(jsonData))
		let router = RouterMock()
		let sut = CharacterContainer(httpClient: httpClient)

		// When - Load characters via list, then get one character via detail
		let listViewModel = sut.makeCharacterListViewModel(router: router)
		await listViewModel.load()

		let detailViewModel = sut.makeCharacterDetailViewModel(identifier: 1, router: router)
		await detailViewModel.load()

		// Then - Detail should use cached character from list response (only 1 HTTP call total)
		#expect(httpClient.requestedEndpoints.count == 1)
	}
}

private final class BundleToken {}
