import ChallengeCore

enum CharacterListEvent: TrackingEventContract {
    case screenViewed
    case characterSelected(identifier: Int)
    case searchPerformed(query: String)
    case retryButtonTapped
    case pullToRefreshTriggered
    case loadMoreButtonTapped
    case characterFilterButtonTapped
    case fetchError(description: String)
    case refreshError(description: String)
    case loadMoreError(description: String)

    var name: String {
        switch self {
        case .screenViewed:
            "character_list_viewed"
        case .characterSelected:
            "character_selected"
        case .searchPerformed:
            "search_performed"
        case .retryButtonTapped:
            "character_list_retry_tapped"
        case .pullToRefreshTriggered:
            "character_list_pull_to_refresh"
        case .loadMoreButtonTapped:
            "character_list_load_more_tapped"
        case .characterFilterButtonTapped:
            "character_list_character_filter_tapped"
        case .fetchError:
            "character_list_fetch_error"
        case .refreshError:
            "character_list_refresh_error"
        case .loadMoreError:
            "character_list_load_more_error"
        }
    }

    var properties: [String: String] {
        switch self {
        case .characterSelected(let identifier):
            ["id": "\(identifier)"]
        case .searchPerformed(let query):
            ["query": query]
        case .fetchError(let description), .refreshError(let description), .loadMoreError(let description):
            ["description": description]
        default:
            [:]
        }
    }
}
