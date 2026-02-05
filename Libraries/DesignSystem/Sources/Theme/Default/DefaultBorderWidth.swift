import Foundation

/// Default border width implementation matching the standard design system scale.
public struct DefaultBorderWidth: DSBorderWidthContract {
	public init() {}

	public var hairline: CGFloat { 0.5 }
	public var thin: CGFloat { 1 }
	public var medium: CGFloat { 2 }
	public var thick: CGFloat { 4 }
}
