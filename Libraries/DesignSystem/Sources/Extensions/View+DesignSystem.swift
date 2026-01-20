import SwiftUI

/// View extensions for design system conveniences.
public extension View {
	/// Applies standard card styling to the view.
	/// - Parameters:
	///   - padding: The internal padding (default: lg)
	///   - cornerRadius: The corner radius (default: lg)
	///   - shadowToken: The shadow style (default: small)
	/// - Returns: A view with card styling applied
	func dsCard(
		padding: CGFloat = SpacingToken.lg,
		cornerRadius: CGFloat = CornerRadiusToken.lg,
		shadowToken: ShadowToken = .small
	) -> some View {
		self
			.padding(padding)
			.background(ColorToken.surfacePrimary)
			.clipShape(RoundedRectangle(cornerRadius: cornerRadius))
			.shadow(shadowToken)
	}

	/// Applies the design system background color.
	/// - Parameter color: The background color token
	/// - Returns: A view with the background applied
	func dsBackground(_ color: Color = ColorToken.backgroundPrimary) -> some View {
		background(color)
	}

	/// Applies corner radius from the design system.
	/// - Parameter radius: The corner radius token value
	/// - Returns: A view with the corner radius applied
	func dsCornerRadius(_ radius: CGFloat = CornerRadiusToken.md) -> some View {
		clipShape(RoundedRectangle(cornerRadius: radius))
	}
}
