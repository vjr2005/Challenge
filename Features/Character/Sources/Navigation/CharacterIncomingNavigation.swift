import ChallengeCore

public enum CharacterIncomingNavigation: Navigation {
    case list
    case detail(identifier: Int)
}
