import ChallengeCore

enum HomeEvent: TrackingEventContract {
    case screenViewed
    case characterButtonTapped
    case infoButtonTapped

    var name: String {
        switch self {
        case .screenViewed:
            "home_viewed"
        case .characterButtonTapped:
            "home_character_button_tapped"
        case .infoButtonTapped:
            "home_info_button_tapped"
        }
    }
}
