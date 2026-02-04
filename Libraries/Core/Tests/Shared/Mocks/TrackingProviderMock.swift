import Foundation

@testable import ChallengeCore

final class TrackingProviderMock: TrackingProviderContract, @unchecked Sendable {
    private(set) var configureCallCount = 0
    private(set) var trackedEvents: [(name: String, properties: [String: String])] = []

    func configure() {
        configureCallCount += 1
    }

    func track(_ event: any TrackingEvent) {
        trackedEvents.append((name: event.name, properties: event.properties))
    }
}
