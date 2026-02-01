import SwiftUI

/// A generic card container with consistent styling.
///
/// DSCard propagates accessibility identifiers to its content. When you apply
/// an accessibility identifier to a DSCard, child Design System components
/// will automatically receive it with their default suffixes.
public struct DSCard<Content: View>: View {
	private let content: Content
	private let padding: CGFloat
	private let cornerRadius: CGFloat
	private let shadow: ShadowToken

	/// Creates a DSCard.
	/// - Parameters:
	///   - padding: The internal padding (default: lg)
	///   - cornerRadius: The corner radius (default: lg)
	///   - shadow: The shadow style (default: small)
	///   - content: The content view builder
	public init(
		padding: CGFloat = SpacingToken.lg,
		cornerRadius: CGFloat = CornerRadiusToken.lg,
		shadow: ShadowToken = .small,
		@ViewBuilder content: () -> Content
	) {
		self.padding = padding
		self.cornerRadius = cornerRadius
		self.shadow = shadow
		self.content = content()
	}

	public var body: some View {
		content
			.padding(padding)
			.background(ColorToken.surfacePrimary)
			.clipShape(RoundedRectangle(cornerRadius: cornerRadius))
			.shadow(shadow)
	}
}

#Preview("DSCard") {
	VStack(spacing: SpacingToken.lg) {
		DSCard {
			VStack(alignment: .leading, spacing: SpacingToken.sm) {
				Text("Card Title")
					.font(TextStyle.headline.font)
					.foregroundStyle(ColorToken.textPrimary)
				Text("This is the card content with some description text.")
					.font(TextStyle.body.font)
					.foregroundStyle(ColorToken.textPrimary)
			}
		}

		DSCard(shadow: .medium) {
			HStack {
				Text("Medium Shadow")
					.font(TextStyle.body.font)
					.foregroundStyle(ColorToken.textPrimary)
				Spacer()
				Image(systemName: "arrow.right")
			}
		}

		DSCard(shadow: .zero) {
			Text("No Shadow Card")
				.font(TextStyle.body.font)
				.foregroundStyle(ColorToken.textPrimary)
		}
	}
	.padding()
	.background(ColorToken.backgroundSecondary)
}
