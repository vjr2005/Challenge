import ChallengeCore

enum NotFoundEvent: TrackingEventContract {
    case screenViewed
    case goBackButtonTapped

    var name: String {
        switch self {
        case .screenViewed:
            "not_found_viewed"
        case .goBackButtonTapped:
            "not_found_go_back_tapped"
        }
    }
}
