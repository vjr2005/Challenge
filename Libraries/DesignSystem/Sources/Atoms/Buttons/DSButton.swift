import SwiftUI

/// Button variants for the design system.
public enum DSButtonVariant {
	/// Primary action button with filled background
	case primary

	/// Secondary button with outlined style
	case secondary

	/// Tertiary button with minimal styling
	case tertiary
}

/// A button component that follows the design system.
public struct DSButton: View {
	private let title: String
	private let icon: String?
	private let variant: DSButtonVariant
	private let isLoading: Bool
	private let action: () -> Void

	/// Creates a DSButton.
	/// - Parameters:
	///   - title: The button title
	///   - icon: Optional SF Symbol name
	///   - variant: The button variant (default: .primary)
	///   - isLoading: Whether to show loading state (default: false)
	///   - action: The action to perform when tapped
	public init(
		_ title: String,
		icon: String? = nil,
		variant: DSButtonVariant = .primary,
		isLoading: Bool = false,
		action: @escaping () -> Void
	) {
		self.title = title
		self.icon = icon
		self.variant = variant
		self.isLoading = isLoading
		self.action = action
	}

	public var body: some View {
		Button(action: action) {
			HStack(spacing: SpacingToken.sm) {
				if isLoading {
					ProgressView()
						.tint(foregroundColor)
				} else if let icon {
					Image(systemName: icon)
				}
				Text(title)
			}
			.font(TextStyle.headline.font)
			.foregroundStyle(foregroundColor)
			.padding(.horizontal, horizontalPadding)
			.padding(.vertical, verticalPadding)
			.frame(maxWidth: variant == .primary ? .infinity : nil)
			.background(backgroundColor)
			.clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.md))
			.overlay {
				if variant == .secondary {
					RoundedRectangle(cornerRadius: CornerRadiusToken.md)
						.stroke(ColorToken.accent, lineWidth: BorderWidthToken.thin)
				}
			}
		}
		.disabled(isLoading)
	}

	private var foregroundColor: Color {
		switch variant {
		case .primary:
			ColorToken.textInverted
		case .secondary, .tertiary:
			ColorToken.accent
		}
	}

	private var backgroundColor: Color {
		switch variant {
		case .primary:
			ColorToken.accent
		case .secondary:
			Color.clear
		case .tertiary:
			ColorToken.accentSubtle
		}
	}

	private var horizontalPadding: CGFloat {
		switch variant {
		case .primary:
			SpacingToken.lg
		case .secondary, .tertiary:
			SpacingToken.md
		}
	}

	private var verticalPadding: CGFloat {
		switch variant {
		case .primary:
			SpacingToken.md
		case .secondary, .tertiary:
			SpacingToken.sm
		}
	}
}

#Preview("DSButton Variants") {
	VStack(spacing: SpacingToken.lg) {
		DSButton("Primary Button") {}
		DSButton("With Icon", icon: "arrow.right") {}
		DSButton("Secondary", variant: .secondary) {}
		DSButton("Secondary Icon", icon: "plus", variant: .secondary) {}
		DSButton("Tertiary", variant: .tertiary) {}
		DSButton("Tertiary Icon", icon: "gear", variant: .tertiary) {}
		DSButton("Loading", isLoading: true) {}
	}
	.padding()
}
