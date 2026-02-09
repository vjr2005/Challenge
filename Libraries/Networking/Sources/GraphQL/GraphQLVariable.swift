import Foundation

/// Represents a variable value in a GraphQL operation.
public enum GraphQLVariable: Encodable, Sendable, Equatable {
	case string(String)
	case int(Int)
	case bool(Bool)
	case null

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		switch self {
		case .string(let value):
			try container.encode(value)
		case .int(let value):
			try container.encode(value)
		case .bool(let value):
			try container.encode(value)
		case .null:
			try container.encodeNil()
		}
	}
}
