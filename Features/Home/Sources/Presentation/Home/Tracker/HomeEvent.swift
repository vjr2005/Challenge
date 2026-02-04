import ChallengeCore

enum HomeEvent: TrackingEvent {
    case screenViewed
    case characterButtonTapped

    var name: String {
        switch self {
        case .screenViewed:
            "home_viewed"
        case .characterButtonTapped:
            "home_character_button_tapped"
        }
    }
}
