import SwiftUI

/// Default shadow implementation matching the standard design system scale.
public struct DefaultShadow: DSShadow {
	public init() {}

	public var zero: DSShadowValue {
		DSShadowValue(color: .clear, radius: 0, x: 0, y: 0)
	}

	public var small: DSShadowValue {
		DSShadowValue(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
	}

	public var medium: DSShadowValue {
		DSShadowValue(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
	}

	public var large: DSShadowValue {
		DSShadowValue(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
	}
}
