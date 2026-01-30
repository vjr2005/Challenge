import SwiftUI
import Testing

@testable import ChallengeCore
@testable import ChallengeCoreMocks

struct ViewFeatureNavigationTests {
    @Test
    func withNavigationDestinationsAppliesAllFeatures() {
        // Given
        let feature1 = FeatureMock()
        let feature2 = FeatureMock()
        let feature3 = FeatureMock()
        let features: [any Feature] = [feature1, feature2, feature3]
        let navigator = NavigatorMock()
        let view = Text("Test")

        // When
        _ = view.withNavigationDestinations(features: features, navigator: navigator)

        // Then
        #expect(feature1.applyNavigationDestinationCallCount == 1)
        #expect(feature2.applyNavigationDestinationCallCount == 1)
        #expect(feature3.applyNavigationDestinationCallCount == 1)
    }

    @Test
    func withNavigationDestinationsPassesNavigatorToFeatures() {
        // Given
        let feature = FeatureMock()
        let features: [any Feature] = [feature]
        let navigator = NavigatorMock()
        let view = Text("Test")

        // When
        _ = view.withNavigationDestinations(features: features, navigator: navigator)

        // Then
        #expect(feature.lastNavigator as? NavigatorMock === navigator)
    }

    @Test
    func withNavigationDestinationsDoesNotCallFeaturesWhenEmpty() {
        // Given
        let features: [any Feature] = []
        let navigator = NavigatorMock()
        let view = Text("Test")

        // When
        _ = view.withNavigationDestinations(features: features, navigator: navigator)

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
        let navigator = NavigatorMock()
        let view = Text("Test")

        // When
        _ = view.withNavigationDestinations(features: features, navigator: navigator)

        // Then
        #expect(callOrder == ["feature1", "feature2", "feature3"])
    }
}

// MARK: - Test Helpers

private final class FeatureMock: Feature {
    private(set) var applyNavigationDestinationCallCount = 0
    private(set) var lastNavigator: (any NavigatorContract)?
    private let onApply: (() -> Void)?

    init(onApply: (() -> Void)? = nil) {
        self.onApply = onApply
    }

    func applyNavigationDestination<V: View>(to view: V, navigator: any NavigatorContract) -> AnyView {
        applyNavigationDestinationCallCount += 1
        lastNavigator = navigator
        onApply?()
        return AnyView(view)
    }
}
