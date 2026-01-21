import SwiftUI

/// Badge variants for the design system.
public enum DSBadgeVariant {
	/// Success badge (green background)
	case success

	/// Error badge (red background)
	case error

	/// Warning badge (orange background)
	case warning

	/// Neutral badge (gray background)
	case neutral

	/// Accent badge (accent color background)
	case accent

	/// The background color for this variant
	var backgroundColor: Color {
		switch self {
		case .success:
			ColorToken.statusSuccess.opacity(OpacityToken.light)
		case .error:
			ColorToken.statusError.opacity(OpacityToken.light)
		case .warning:
			ColorToken.statusWarning.opacity(OpacityToken.light)
		case .neutral:
			ColorToken.statusNeutral.opacity(OpacityToken.light)
		case .accent:
			ColorToken.accentSubtle
		}
	}

	/// The foreground color for this variant
	var foregroundColor: Color {
		switch self {
		case .success:
			ColorToken.statusSuccess
		case .error:
			ColorToken.statusError
		case .warning:
			ColorToken.statusWarning
		case .neutral:
			ColorToken.statusNeutral
		case .accent:
			ColorToken.accent
		}
	}
}

/// A badge component for displaying labels with semantic colors.
public struct DSBadge: View {
	private let text: String
	private let variant: DSBadgeVariant

	/// Creates a DSBadge.
	/// - Parameters:
	///   - text: The text to display
	///   - variant: The badge variant (default: .neutral)
	public init(_ text: String, variant: DSBadgeVariant = .neutral) {
		self.text = text
		self.variant = variant
	}

	public var body: some View {
		Text(text)
			.font(TextStyle.caption.font)
			.foregroundStyle(variant.foregroundColor)
			.padding(.horizontal, SpacingToken.sm)
			.padding(.vertical, SpacingToken.xs)
			.background(variant.backgroundColor)
			.clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.sm))
	}
}

#if DEBUG
#Preview("DSBadge Variants") {
	VStack(spacing: SpacingToken.md) {
		DSBadge("Success", variant: .success)
		DSBadge("Error", variant: .error)
		DSBadge("Warning", variant: .warning)
		DSBadge("Neutral", variant: .neutral)
		DSBadge("Accent", variant: .accent)
	}
	.padding()
}
#endif
