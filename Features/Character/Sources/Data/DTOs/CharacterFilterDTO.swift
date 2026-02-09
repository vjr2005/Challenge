struct CharacterFilterDTO: Equatable {
	var name: String?
	var status: String?
	var species: String?
	var type: String?
	var gender: String?

	static let empty = CharacterFilterDTO()
}
