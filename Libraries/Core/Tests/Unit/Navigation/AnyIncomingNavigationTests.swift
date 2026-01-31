import Testing

@testable import ChallengeCore

struct AnyIncomingNavigationTests {
    // MARK: - Initialization

    @Test
    func initWrapsNavigation() {
        // Given
        let navigation = TestNavigation.screen1

        // When
        let sut = AnyIncomingNavigation(navigation)

        // Then
        #expect(sut.wrapped as? TestNavigation == .screen1)
    }

    // MARK: - Equality

    @Test
    func equalityReturnsTrueForSameNavigation() {
        // Given
        let navigation1 = AnyIncomingNavigation(TestNavigation.screen1)
        let navigation2 = AnyIncomingNavigation(TestNavigation.screen1)

        // Then
        #expect(navigation1 == navigation2)
    }

    @Test
    func equalityReturnsFalseForDifferentNavigationValues() {
        // Given
        let navigation1 = AnyIncomingNavigation(TestNavigation.screen1)
        let navigation2 = AnyIncomingNavigation(TestNavigation.screen2)

        // Then
        #expect(navigation1 != navigation2)
    }

    @Test
    func equalityReturnsFalseForDifferentNavigationTypes() {
        // Given
        let navigation1 = AnyIncomingNavigation(TestNavigation.screen1)
        let navigation2 = AnyIncomingNavigation(OtherNavigation.other)

        // Then
        #expect(navigation1 != navigation2)
    }

    @Test
    func equalityWorksWithAssociatedValues() {
        // Given
        let navigation1 = AnyIncomingNavigation(TestNavigationWithValue.detail(id: 42))
        let navigation2 = AnyIncomingNavigation(TestNavigationWithValue.detail(id: 42))
        let navigation3 = AnyIncomingNavigation(TestNavigationWithValue.detail(id: 99))

        // Then
        #expect(navigation1 == navigation2)
        #expect(navigation1 != navigation3)
    }

    // MARK: - Hashing

    @Test
    func hashingProducesSameHashForEqualNavigations() {
        // Given
        let navigation1 = AnyIncomingNavigation(TestNavigation.screen1)
        let navigation2 = AnyIncomingNavigation(TestNavigation.screen1)

        // Then
        #expect(navigation1.hashValue == navigation2.hashValue)
    }

    @Test
    func hashingWorksInSets() {
        // Given
        let navigation1 = AnyIncomingNavigation(TestNavigation.screen1)
        let navigation2 = AnyIncomingNavigation(TestNavigation.screen1)
        let navigation3 = AnyIncomingNavigation(TestNavigation.screen2)

        // When
        let set: Set<AnyIncomingNavigation> = [navigation1, navigation2, navigation3]

        // Then
        #expect(set.count == 2)
    }
}

// MARK: - Test Helpers

private enum TestNavigation: IncomingNavigation {
    case screen1
    case screen2
}

private enum OtherNavigation: IncomingNavigation {
    case other
}

private enum TestNavigationWithValue: IncomingNavigation {
    case detail(id: Int)
}
