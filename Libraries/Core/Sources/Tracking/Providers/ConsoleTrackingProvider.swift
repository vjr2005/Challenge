import Foundation
import OSLog

/// Tracking provider that logs events to the console using os_log.
/// Intended for development and debugging purposes.
public struct ConsoleTrackingProvider: TrackingProviderContract {
    private let logger = Logger(subsystem: "com.challenge", category: "Tracking")

    public init() {}

    public func track(_ event: any TrackingEventContract) {
        if event.properties.isEmpty {
            logger.info("[\(event.name)]")
        } else {
            let formatted = event.properties
                .sorted { $0.key < $1.key }
                .map { "\($0.key): \($0.value)" }
                .joined(separator: ", ")
            logger.info("[\(event.name)] \(formatted)")
        }
    }
}
