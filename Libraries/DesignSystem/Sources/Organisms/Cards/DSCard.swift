import SwiftUI

/// A generic card container with consistent styling.
///
/// DSCard propagates accessibility identifiers to its content. When you apply
/// an accessibility identifier to a DSCard, child Design System components
/// will automatically receive it with their default suffixes.
public struct DSCard<Content: View>: View {
	private let content: Content
	private let padding: CGFloat?
	private let cornerRadius: CGFloat?
	private let shadow: DSShadowValue?

	@Environment(\.dsTheme) private var theme

	/// Creates a DSCard.
	/// - Parameters:
	///   - padding: The internal padding (default: theme lg spacing)
	///   - cornerRadius: The corner radius (default: theme lg corner radius)
	///   - shadow: The shadow style (default: theme small shadow)
	///   - content: The content view builder
	public init(
		padding: CGFloat? = nil,
		cornerRadius: CGFloat? = nil,
		shadow: DSShadowValue? = nil,
		@ViewBuilder content: () -> Content
	) {
		self.padding = padding
		self.cornerRadius = cornerRadius
		self.shadow = shadow
		self.content = content()
	}

	public var body: some View {
		content
			.padding(padding ?? theme.spacing.lg)
			.background(theme.colors.surfacePrimary)
			.clipShape(RoundedRectangle(cornerRadius: cornerRadius ?? theme.cornerRadius.lg))
			.shadow(shadow ?? theme.shadow.small)
	}
}

/*
// MARK: - Previews

#Preview("DSCard") {
	VStack(spacing: SpacingToken.lg) {
		DSCard {
			VStack(alignment: .leading, spacing: SpacingToken.sm) {
				Text("Card Title")
					.font(DefaultTypography().headline)
					.foregroundStyle(ColorToken.textPrimary)
				Text("This is the card content with some description text.")
					.font(DefaultTypography().body)
					.foregroundStyle(ColorToken.textPrimary)
			}
		}

		DSCard(shadow: .medium) {
			HStack {
				Text("Medium Shadow")
					.font(DefaultTypography().body)
					.foregroundStyle(ColorToken.textPrimary)
				Spacer()
				Image(systemName: "arrow.right")
			}
		}

		DSCard(shadow: .zero) {
			Text("No Shadow Card")
				.font(DefaultTypography().body)
				.foregroundStyle(ColorToken.textPrimary)
		}
	}
	.padding()
	.background(ColorToken.backgroundSecondary)
}
*/
