import ChallengeCore

enum AboutEvent: TrackingEventContract {
    case screenViewed

    var name: String {
        switch self {
        case .screenViewed:
            "about_viewed"
        }
    }
}
