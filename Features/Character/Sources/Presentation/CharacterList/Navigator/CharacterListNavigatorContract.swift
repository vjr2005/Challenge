protocol CharacterListNavigatorContract {
    func navigateToDetail(identifier: Int)
    func presentCharacterFilter(delegate: any CharacterFilterDelegate)
}
