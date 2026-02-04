import Foundation

/// Default opacity implementation matching the standard design system scale.
public struct DefaultOpacity: DSOpacity {
	public init() {}

	public var subtle: Double { 0.1 }
	public var light: Double { 0.15 }
	public var medium: Double { 0.4 }
	public var heavy: Double { 0.6 }
	public var almostOpaque: Double { 0.8 }
}
