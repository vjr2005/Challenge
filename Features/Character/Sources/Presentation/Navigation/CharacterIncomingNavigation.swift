import ChallengeCore

public enum CharacterIncomingNavigation: IncomingNavigation {
    case list
    case detail(identifier: Int)
}
