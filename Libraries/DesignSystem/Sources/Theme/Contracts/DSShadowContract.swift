import SwiftUI

/// A shadow value combining color, radius, and offset.
public struct DSShadowValue: Sendable, Equatable {
	/// Shadow color
	public let color: Color
	/// Shadow blur radius
	public let radius: CGFloat
	/// Shadow X offset
	public let x: CGFloat
	/// Shadow Y offset
	public let y: CGFloat

	/// Creates a new shadow value.
	/// - Parameters:
	///   - color: The shadow color
	///   - radius: The shadow blur radius
	///   - x: The shadow X offset
	///   - y: The shadow Y offset
	public init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
		self.color = color
		self.radius = radius
		self.x = x
		self.y = y
	}
}

/// Contract for design system shadow values.
///
/// Conforming types provide shadow values for all design system components.
/// Each property maps to a semantic shadow level from zero to large.
public protocol DSShadowContract: Sendable {
	/// No shadow
	var zero: DSShadowValue { get }

	/// Small subtle shadow for cards
	var small: DSShadowValue { get }

	/// Medium shadow for elevated elements
	var medium: DSShadowValue { get }

	/// Large shadow for floating elements
	var large: DSShadowValue { get }
}

/// View extension for applying shadow values
public extension View {
	/// Applies a shadow value to the view
	/// - Parameter value: The shadow value to apply
	/// - Returns: A view with the shadow applied
	func shadow(_ value: DSShadowValue) -> some View {
		shadow(color: value.color, radius: value.radius, x: value.x, y: value.y)
	}
}
