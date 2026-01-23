import ChallengeCommon
import ChallengeCore
import ChallengeNetworking
import SwiftUI

public struct CharacterFeature: Feature {
    // MARK: - Dependencies

    private let httpClient: any HTTPClientContract
    private let memoryDataSource = CharacterMemoryDataSource()

    private var repository: any CharacterRepositoryContract {
        CharacterRepository(
            remoteDataSource: CharacterRemoteDataSource(httpClient: httpClient),
            memoryDataSource: memoryDataSource
        )
    }

    // MARK: - Init

    public init(httpClient: (any HTTPClientContract)? = nil) {
        self.httpClient = httpClient ?? HTTPClient(baseURL: AppEnvironment.current.rickAndMorty.baseURL)
    }

    // MARK: - Feature Protocol

    public func registerDeepLinks() {
        CharacterDeepLinkHandler.register()
    }

    public func applyNavigationDestination<V: View>(to view: V, router: any RouterContract) -> AnyView {
        AnyView(
            view.navigationDestination(for: CharacterNavigation.self) { navigation in
                self.view(for: navigation, router: router)
            }
        )
    }

    // MARK: - Views

    @ViewBuilder
    private func view(for navigation: CharacterNavigation, router: any RouterContract) -> some View {
        switch navigation {
        case .list:
            CharacterListView(viewModel: makeCharacterListViewModel(router: router))
        case .detail(let identifier):
            CharacterDetailView(viewModel: makeCharacterDetailViewModel(identifier: identifier, router: router))
        }
    }

    // MARK: - Factories

    func makeCharacterListViewModel(router: any RouterContract) -> CharacterListViewModel {
        CharacterListViewModel(
            getCharactersUseCase: GetCharactersUseCase(repository: repository),
            navigator: CharacterListNavigator(router: router)
        )
    }

    func makeCharacterDetailViewModel(identifier: Int, router: any RouterContract) -> CharacterDetailViewModel {
        CharacterDetailViewModel(
            identifier: identifier,
            getCharacterUseCase: GetCharacterUseCase(repository: repository),
            navigator: CharacterDetailNavigator(router: router)
        )
    }
}
