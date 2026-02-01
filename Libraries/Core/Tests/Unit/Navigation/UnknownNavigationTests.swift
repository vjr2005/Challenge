import Testing

@testable import ChallengeCore

struct UnknownNavigationTests {
    @Test("Two notFound instances are equal")
    func twoInstancesAreEqual() {
        // Given
        let first = UnknownNavigation.notFound
        let second = UnknownNavigation.notFound

        // Then
        #expect(first == second)
    }

    @Test("UnknownNavigation conforms to Hashable")
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
