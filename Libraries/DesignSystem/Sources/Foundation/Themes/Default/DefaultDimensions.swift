import Foundation

/// Default dimensions implementation matching the standard design system scale.
public struct DefaultDimensions: DSDimensions {
	public init() {}

	public var xs: CGFloat { 8 }
	public var sm: CGFloat { 12 }
	public var md: CGFloat { 16 }
	public var lg: CGFloat { 24 }
	public var xl: CGFloat { 32 }
	public var xxl: CGFloat { 48 }
	public var xxxl: CGFloat { 56 }
}
