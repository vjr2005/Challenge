import SwiftUI

/// Design tokens for shadow styles.
public enum ShadowToken {
	/// No shadow
	case zero

	/// Small subtle shadow for cards
	case small

	/// Medium shadow for elevated elements
	case medium

	/// Large shadow for floating elements
	case large

	/// Shadow color
	public var color: Color {
		switch self {
		case .zero:
			.clear
		case .small:
			.black.opacity(0.05)
		case .medium:
			.black.opacity(0.08)
		case .large:
			.black.opacity(0.12)
		}
	}

	/// Shadow blur radius
	public var radius: CGFloat {
		switch self {
		case .zero:
			0
		case .small:
			8
		case .medium:
			12
		case .large:
			20
		}
	}

	/// Shadow X offset
	public var x: CGFloat {
		0
	}

	/// Shadow Y offset
	public var y: CGFloat {
		switch self {
		case .zero:
			0
		case .small:
			2
		case .medium:
			4
		case .large:
			8
		}
	}
}

/// View extension for applying shadow tokens
public extension View {
	/// Applies a shadow token to the view
	/// - Parameter token: The shadow token to apply
	/// - Returns: A view with the shadow applied
	func shadow(_ token: ShadowToken) -> some View {
		shadow(color: token.color, radius: token.radius, x: token.x, y: token.y)
	}
}
