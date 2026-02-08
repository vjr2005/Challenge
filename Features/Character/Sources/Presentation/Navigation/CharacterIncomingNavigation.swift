import ChallengeCore

public enum CharacterIncomingNavigation: IncomingNavigationContract {
    case list
    case detail(identifier: Int)
    case advancedSearch(delegate: any CharacterFilterDelegate)

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.list, .list):
            return true
        case (.detail(let lhsID), .detail(let rhsID)):
            return lhsID == rhsID
        case (.advancedSearch, .advancedSearch):
            return true
        default:
            return false
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .list:
            hasher.combine(0)
        case .detail(let identifier):
            hasher.combine(1)
            hasher.combine(identifier)
        case .advancedSearch:
            hasher.combine(2)
        }
    }
}
