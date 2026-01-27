import Foundation

public extension Bundle {
    /// Loads and decodes a JSON file from the bundle into the specified type.
    func loadJSON<T: Decodable>(_ filename: String) throws -> T {
        let data = try loadJSONData(filename)
        return try JSONDecoder().decode(T.self, from: data)
    }

    /// Loads raw JSON data from the bundle for the given filename.
    func loadJSONData(_ filename: String) throws -> Data {
        guard let url = url(forResource: filename, withExtension: "json") else {
            throw JSONLoadError.fileNotFound(filename)
        }
        return try Data(contentsOf: url)
    }
}

/// Error thrown when loading a JSON file from a bundle fails.
public enum JSONLoadError: Error, CustomStringConvertible {
    case fileNotFound(String)

    /// A human-readable description of the error.
    public var description: String {
        switch self {
        case let .fileNotFound(filename):
            "JSON file '\(filename).json' not found in bundle"
        }
    }
}
