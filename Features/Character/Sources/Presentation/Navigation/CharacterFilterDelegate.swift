public protocol CharacterFilterDelegate: AnyObject, Sendable {
    var currentFilter: CharacterFilter { get }
    func didApplyFilter(_ filter: CharacterFilter)
}
