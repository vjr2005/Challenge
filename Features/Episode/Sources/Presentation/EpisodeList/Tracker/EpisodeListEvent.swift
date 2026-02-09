import ChallengeCore

enum EpisodeListEvent: TrackingEventContract {
    case screenViewed

    var name: String {
        switch self {
        case .screenViewed:
            "episode_list_viewed"
        }
    }

    var properties: [String: String] {
        switch self {
        case .screenViewed:
            [:]
        }
    }
}
