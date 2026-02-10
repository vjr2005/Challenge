import ChallengeCore

public enum CharacterOutgoingNavigation: OutgoingNavigationContract {
	case episodes(characterIdentifier: Int)
}
