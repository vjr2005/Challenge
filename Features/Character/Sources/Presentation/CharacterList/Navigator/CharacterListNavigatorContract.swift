protocol CharacterListNavigatorContract {
    func navigateToDetail(identifier: Int)
    func presentAdvancedSearch(delegate: any CharacterFilterDelegate)
}
