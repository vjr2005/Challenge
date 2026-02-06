import ChallengeCore

enum AdvancedSearchEvent: TrackingEventContract {
    case screenViewed
    case filtersApplied(filterCount: Int)
    case filtersReset
    case closeTapped

    var name: String {
        switch self {
        case .screenViewed:
            "advanced_search_viewed"
        case .filtersApplied:
            "advanced_search_filters_applied"
        case .filtersReset:
            "advanced_search_filters_reset"
        case .closeTapped:
            "advanced_search_close_tapped"
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
