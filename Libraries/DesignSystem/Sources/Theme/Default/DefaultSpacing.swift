import Foundation

/// Default spacing implementation matching the standard design system scale.
public struct DefaultSpacing: DSSpacing {
	public init() {}

	public var xxs: CGFloat { 2 }
	public var xs: CGFloat { 4 }
	public var sm: CGFloat { 8 }
	public var md: CGFloat { 12 }
	public var lg: CGFloat { 16 }
	public var xl: CGFloat { 20 }
	public var xxl: CGFloat { 24 }
	public var xxxl: CGFloat { 32 }
}
