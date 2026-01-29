import Testing

@testable import ChallengeCore

struct UnknownNavigationTests {
    @Test
    func conformsToIncomingNavigation() {
        // Given
        let sut = UnknownNavigation.notFound

        // Then
        #expect(sut is any IncomingNavigation)
    }

    @Test
    func twoInstancesAreEqual() {
        // Given
        let first = UnknownNavigation.notFound
        let second = UnknownNavigation.notFound

        // Then
        #expect(first == second)
    }

    @Test
    func conformsToHashable() {
        // Given
        let sut = UnknownNavigation.notFound
        var set = Set<UnknownNavigation>()

        // When
        set.insert(sut)

        // Then
        #expect(set.contains(sut))
    }
}
