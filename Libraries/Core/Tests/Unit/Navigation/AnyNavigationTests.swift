import Testing

@testable import ChallengeCore

struct AnyNavigationTests {
    // MARK: - Initialization

    @Test("Init wraps navigation in type-erased container")
    func initWrapsNavigation() {
        // Given
        let navigation = TestNavigation.screen1

        // When
        let sut = AnyNavigation(navigation)

        // Then
        #expect(sut.wrapped as? TestNavigation == .screen1)
    }

    // MARK: - Equality

    @Test("Equality returns true for same navigation value")
    func equalityReturnsTrueForSameNavigation() {
        // Given
        let navigation1 = AnyNavigation(TestNavigation.screen1)
        let navigation2 = AnyNavigation(TestNavigation.screen1)

        // Then
        #expect(navigation1 == navigation2)
    }

    @Test("Equality returns false for different values with same hash")
    func equalityReturnsFalseForDifferentValuesWithSameHash() {
        // Given
        let navigation1 = AnyNavigation(CollidingNavigation.value1)
        let navigation2 = AnyNavigation(CollidingNavigation.value2)

        // Then
        #expect(navigation1 != navigation2)
    }

    @Test("Equality returns false for different navigation values")
    func equalityReturnsFalseForDifferentNavigationValues() {
        // Given
        let navigation1 = AnyNavigation(TestNavigation.screen1)
        let navigation2 = AnyNavigation(TestNavigation.screen2)

        // Then
        #expect(navigation1 != navigation2)
    }

    @Test("Equality returns false for different navigation types")
    func equalityReturnsFalseForDifferentNavigationTypes() {
        // Given
        let navigation1 = AnyNavigation(TestNavigation.screen1)
        let navigation2 = AnyNavigation(OtherNavigation.other)

        // Then
        #expect(navigation1 != navigation2)
    }

    @Test("Equality works correctly with associated values")
    func equalityWorksWithAssociatedValues() {
        // Given
        let navigation1 = AnyNavigation(TestNavigationWithValue.detail(identifier: 42))
        let navigation2 = AnyNavigation(TestNavigationWithValue.detail(identifier: 42))
        let navigation3 = AnyNavigation(TestNavigationWithValue.detail(identifier: 99))

        // Then
        #expect(navigation1 == navigation2)
        #expect(navigation1 != navigation3)
    }

    // MARK: - Hashing

    @Test("Hashing produces same hash for equal navigations")
    func hashingProducesSameHashForEqualNavigations() {
        // Given
        let navigation1 = AnyNavigation(TestNavigation.screen1)
        let navigation2 = AnyNavigation(TestNavigation.screen1)

        // Then
        #expect(navigation1.hashValue == navigation2.hashValue)
    }

    @Test("Hashing works correctly in Set collections")
    func hashingWorksInSets() {
        // Given
        let navigation1 = AnyNavigation(TestNavigation.screen1)
        let navigation2 = AnyNavigation(TestNavigation.screen1)
        let navigation3 = AnyNavigation(TestNavigation.screen2)

        // When
        let set: Set<AnyNavigation> = [navigation1, navigation2, navigation3]

        // Then
        #expect(set.count == 2)
    }
}

// MARK: - Test Helpers

private enum TestNavigation: IncomingNavigationContract {
    case screen1
    case screen2
}

private enum OtherNavigation: IncomingNavigationContract {
    case other
}

private enum TestNavigationWithValue: IncomingNavigationContract {
    case detail(identifier: Int)
}

/// Two distinct values that produce the same hash, used to verify equality is value-based, not hash-based.
private enum CollidingNavigation: IncomingNavigationContract {
    case value1
    case value2

    func hash(into hasher: inout Hasher) {
        hasher.combine(0)
    }
}
