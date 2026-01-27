import Foundation

public extension Bundle {
    func loadJSON<T: Decodable>(_ filename: String) throws -> T {
        let data = try loadJSONData(filename)
        return try JSONDecoder().decode(T.self, from: data)
    }

    func loadJSONData(_ filename: String) throws -> Data {
        guard let url = url(forResource: filename, withExtension: "json") else {
            throw JSONLoadError.fileNotFound(filename)
        }
        return try Data(contentsOf: url)
    }
}

public enum JSONLoadError: Error, CustomStringConvertible {
    case fileNotFound(String)

    public var description: String {
        switch self {
        case let .fileNotFound(filename):
            "JSON file '\(filename).json' not found in bundle"
        }
    }
}
