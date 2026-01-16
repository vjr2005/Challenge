import Foundation

/// Public entry point for the Networking module.
/// Exposes all public contracts and their factory methods.
public enum Networking {
    /// Creates an HTTP client instance.
    /// - Parameters:
    ///   - baseURL: The base URL for all requests.
    ///   - session: URLSession to use. Defaults to `.shared`.
    ///   - decoder: JSONDecoder for response parsing. Defaults to `JSONDecoder()`.
    /// - Returns: An HTTP client conforming to `HTTPClientContract`.
    public static func makeHTTPClient(
        baseURL: URL,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) -> any HTTPClientContract {
        HTTPClient(baseURL: baseURL, session: session, decoder: decoder)
    }
}
