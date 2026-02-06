import ChallengeCore

public enum CharacterIncomingNavigation: IncomingNavigationContract {
    case list
    case detail(identifier: Int)
    case advancedSearch
}
