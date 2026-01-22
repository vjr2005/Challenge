import Foundation

/// Central registry for deep link handlers.
/// Supports dynamic registration of handlers at runtime.
public final class DeepLinkRegistry: @unchecked Sendable {
    public static let shared = DeepLinkRegistry()

    private var handlers: [String: any DeepLinkHandler] = [:]
    private let lock = NSLock()

    public init() {}

    /// Registers a handler for deep link resolution.
    /// - Parameter handler: The handler to register.
    public func register(_ handler: any DeepLinkHandler) {
        let key = "\(handler.scheme)://\(handler.host)"
        lock.lock()
        handlers[key] = handler
        lock.unlock()
    }

    public func resolve(_ url: URL) -> (any Navigation)? {
        guard let scheme = url.scheme, let host = url.host else {
            return nil
        }
        let key = "\(scheme)://\(host)"
        lock.lock()
        let handler = handlers[key]
        lock.unlock()
        return handler?.resolve(url)
    }
}
