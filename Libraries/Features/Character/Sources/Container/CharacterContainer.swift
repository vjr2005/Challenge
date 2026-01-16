import ChallengeCore
import ChallengeNetworking
import Foundation

final class CharacterContainer {
    // MARK: - Infrastructure

    private let httpClient: any HTTPClientContract

    init(httpClient: (any HTTPClientContract)? = nil) {
        self.httpClient = httpClient ?? HTTPClient(baseURL: APIConfiguration.rickAndMorty.baseURL)
    }

    // MARK: - Shared (lazy) - Source of Truth

    private let memoryDataSource = CharacterMemoryDataSource()

    private lazy var repository: any CharacterRepositoryContract = CharacterRepository(
        remoteDataSource: CharacterRemoteDataSource(httpClient: httpClient),
        memoryDataSource: memoryDataSource
    )

    // MARK: - Factories

    func makeCharacterDetailViewModel(identifier: Int, router: RouterContract) -> CharacterDetailViewModel {
        CharacterDetailViewModel(
            identifier: identifier,
            getCharacterUseCase: makeGetCharacterUseCase(),
            router: router
        )
    }

    private func makeGetCharacterUseCase() -> some GetCharacterUseCaseContract {
        GetCharacterUseCase(repository: repository)
    }
}
