import ChallengeCore

enum CharacterFilterEvent: TrackingEventContract {
    case screenViewed
    case filtersApplied(filterCount: Int)
    case filtersReset
    case closeTapped

    var name: String {
        switch self {
        case .screenViewed:
            "character_filter_viewed"
        case .filtersApplied:
            "character_filter_filters_applied"
        case .filtersReset:
            "character_filter_filters_reset"
        case .closeTapped:
            "character_filter_close_tapped"
        }
    }

    var properties: [String: String] {
        switch self {
        case .filtersApplied(let filterCount):
            ["filter_count": "\(filterCount)"]
        default:
            [:]
        }
    }
}
