import SwiftUI

/// View extensions for design system conveniences.
public extension View {
	/// Applies standard card styling to the view.
	/// - Parameters:
	///   - padding: The internal padding (default: theme lg spacing)
	///   - cornerRadius: The corner radius (default: theme lg corner radius)
	///   - shadowToken: The shadow style (default: small)
	/// - Returns: A view with card styling applied
	func dsCard(
		padding: CGFloat? = nil,
		cornerRadius: CGFloat? = nil,
		shadowToken: ShadowToken = .small
	) -> some View {
		modifier(DSCardModifier(padding: padding, cornerRadius: cornerRadius, shadowToken: shadowToken))
	}

	/// Applies the design system background color.
	/// - Parameter color: The background color token
	/// - Returns: A view with the background applied
	func dsBackground(_ color: Color) -> some View {
		background(color)
	}

	/// Applies corner radius from the design system.
	/// - Parameter radius: The corner radius value (default: theme md corner radius)
	/// - Returns: A view with the corner radius applied
	func dsCornerRadius(_ radius: CGFloat? = nil) -> some View {
		modifier(DSCornerRadiusModifier(radius: radius))
	}
}

private struct DSCardModifier: ViewModifier {
	let padding: CGFloat?
	let cornerRadius: CGFloat?
	let shadowToken: ShadowToken

	@Environment(\.dsTheme) private var theme

	func body(content: Content) -> some View {
		content
			.padding(padding ?? theme.spacing.lg)
			.background(theme.colors.surfacePrimary)
			.clipShape(RoundedRectangle(cornerRadius: cornerRadius ?? theme.cornerRadius.lg))
			.shadow(shadowToken)
	}
}

private struct DSCornerRadiusModifier: ViewModifier {
	let radius: CGFloat?

	@Environment(\.dsTheme) private var theme

	func body(content: Content) -> some View {
		content
			.clipShape(RoundedRectangle(cornerRadius: radius ?? theme.cornerRadius.md))
	}
}
