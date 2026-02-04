import Foundation

/// Default corner radius implementation matching the standard design system scale.
public struct DefaultCornerRadius: DSCornerRadius {
	public init() {}

	public var zero: CGFloat { 0 }
	public var xs: CGFloat { 4 }
	public var sm: CGFloat { 8 }
	public var md: CGFloat { 12 }
	public var lg: CGFloat { 16 }
	public var xl: CGFloat { 20 }
	public var full: CGFloat { 9999 }
}
