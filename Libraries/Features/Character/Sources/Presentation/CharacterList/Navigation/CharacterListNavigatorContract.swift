/// Defines navigation actions from Character List screen.
protocol CharacterListNavigatorContract {
    /// Navigates to character detail (INTERNAL navigation).
    func navigateToDetail(id: Int)
}
