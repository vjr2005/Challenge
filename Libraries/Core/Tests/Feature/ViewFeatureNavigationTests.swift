import SwiftUI
import Testing

@testable import ChallengeCore
@testable import ChallengeCoreMocks

@Suite(.timeLimit(.minutes(1)))
struct ViewFeatureNavigationTests {
    @Test
    func withNavigationDestinationsAppliesAllFeatures() {
        // Given
        let feature1 = FeatureMock()
        let feature2 = FeatureMock()
        let feature3 = FeatureMock()
        let features: [any Feature] = [feature1, feature2, feature3]
        let router = RouterMock()
        let view = Text("Test")

        // When
        _ = view.withNavigationDestinations(features: features, router: router)

        // Then
        #expect(feature1.applyNavigationDestinationCallCount == 1)
        #expect(feature2.applyNavigationDestinationCallCount == 1)
        #expect(feature3.applyNavigationDestinationCallCount == 1)
    }

    @Test
    func withNavigationDestinationsPassesRouterToFeatures() {
        // Given
        let feature = FeatureMock()
        let features: [any Feature] = [feature]
        let router = RouterMock()
        let view = Text("Test")

        // When
        _ = view.withNavigationDestinations(features: features, router: router)

        // Then
        #expect(feature.lastRouter as? RouterMock === router)
    }

    @Test
    func withNavigationDestinationsDoesNotCallFeaturesWhenEmpty() {
        // Given
        let features: [any Feature] = []
        let router = RouterMock()
        let view = Text("Test")

        // When
        _ = view.withNavigationDestinations(features: features, router: router)

        // Then
        #expect(features.isEmpty)
    }

    @Test
    func withNavigationDestinationsAppliesFeaturesInOrder() {
        // Given
        var callOrder: [String] = []
        let feature1 = FeatureMock { callOrder.append("feature1") }
        let feature2 = FeatureMock { callOrder.append("feature2") }
        let feature3 = FeatureMock { callOrder.append("feature3") }
        let features: [any Feature] = [feature1, feature2, feature3]
        let router = RouterMock()
        let view = Text("Test")

        // When
        _ = view.withNavigationDestinations(features: features, router: router)

        // Then
        #expect(callOrder == ["feature1", "feature2", "feature3"])
    }
}

// MARK: - Test Helpers

private final class FeatureMock: Feature {
    private(set) var applyNavigationDestinationCallCount = 0
    private(set) var registerDeepLinksCallCount = 0
    private(set) var lastRouter: (any RouterContract)?
    private let onApply: (() -> Void)?

    init(onApply: (() -> Void)? = nil) {
        self.onApply = onApply
    }

    func registerDeepLinks() {
        registerDeepLinksCallCount += 1
    }

    func applyNavigationDestination<V: View>(to view: V, router: any RouterContract) -> AnyView {
        applyNavigationDestinationCallCount += 1
        lastRouter = router
        onApply?()
        return AnyView(view)
    }
}
