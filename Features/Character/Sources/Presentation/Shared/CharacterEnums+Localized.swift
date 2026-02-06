import ChallengeResources

extension CharacterStatus {
	var localizedName: String {
		switch self {
		case .alive: "characterStatus.alive".localized()
		case .dead: "characterStatus.dead".localized()
		case .unknown: "characterStatus.unknown".localized()
		}
	}
}

extension CharacterGender {
	var localizedName: String {
		switch self {
		case .female: "characterGender.female".localized()
		case .male: "characterGender.male".localized()
		case .genderless: "characterGender.genderless".localized()
		case .unknown: "characterGender.unknown".localized()
		}
	}
}
