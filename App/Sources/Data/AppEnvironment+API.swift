import ChallengeCore
import Foundation

// MARK: - API Configuration

extension AppEnvironment {
    struct API {
        let baseURL: URL
    }

    // swiftlint:disable force_unwrapping
    private enum URLs {
        // TODO: Replace with development environment URL
        static let development = URL(string: "https://rickandmortyapi.com/api")!
        // TODO: Replace with staging environment URL
        static let staging = URL(string: "https://rickandmortyapi.com/api")!
        // TODO: Replace with production environment URL
        static let production = URL(string: "https://rickandmortyapi.com/api")!
    }
    // swiftlint:enable force_unwrapping

    var rickAndMorty: API {
        let url: URL
        switch self {
        case .development:
            url = URLs.development
        case .staging:
            url = URLs.staging
        case .production:
            url = URLs.production
        }
        return API(baseURL: url)
    }
}
