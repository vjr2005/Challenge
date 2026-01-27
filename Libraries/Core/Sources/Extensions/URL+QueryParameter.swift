import Foundation

public extension URL {
    /// Returns the value of the query parameter with the given name.
    func queryParameter(_ name: String) -> String? {
        URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first { $0.name == name }?
            .value
    }
}
