import SwiftUI

/// A generic card container with consistent styling.
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
				DSText("Card Title", style: .headline)
				DSText("This is the card content with some description text.", style: .body)
			}
		}

		DSCard(shadow: .medium) {
			HStack {
				DSText("Medium Shadow", style: .body)
				Spacer()
				Image(systemName: "arrow.right")
			}
		}

		DSCard(shadow: .zero) {
			DSText("No Shadow Card", style: .body)
		}
	}
	.padding()
	.background(ColorToken.backgroundSecondary)
}
