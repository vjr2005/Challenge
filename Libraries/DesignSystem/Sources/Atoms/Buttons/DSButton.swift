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
	private let accessibilityIdentifier: String?
	private let action: () -> Void

	@Environment(\.dsTheme) private var theme

	/// Creates a DSButton.
	/// - Parameters:
	///   - title: The button title
	///   - icon: Optional SF Symbol name
	///   - variant: The button variant (default: .primary)
	///   - isLoading: Whether to show loading state (default: false)
	///   - accessibilityIdentifier: Optional accessibility identifier for UI testing
	///   - action: The action to perform when tapped
	public init(
		_ title: String,
		icon: String? = nil,
		variant: DSButtonVariant = .primary,
		isLoading: Bool = false,
		accessibilityIdentifier: String? = nil,
		action: @escaping () -> Void
	) {
		self.title = title
		self.icon = icon
		self.variant = variant
		self.isLoading = isLoading
		self.accessibilityIdentifier = accessibilityIdentifier
		self.action = action
	}

	public var body: some View {
		Button(action: action) {
			HStack(spacing: theme.spacing.sm) {
				if isLoading {
					ProgressView()
						.tint(foregroundColor)
						.accessibilityHidden(true)
				} else if let icon {
					Image(systemName: icon)
						.accessibilityHidden(true)
				}
				Text(title)
			}
			.font(theme.typography.font(for: .headline))
			.foregroundStyle(foregroundColor)
			.padding(.horizontal, horizontalPadding)
			.padding(.vertical, verticalPadding)
			.frame(maxWidth: variant == .primary ? .infinity : nil)
			.background(backgroundColor)
			.clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.md))
			.overlay {
				if variant == .secondary {
					RoundedRectangle(cornerRadius: CornerRadiusToken.md)
						.stroke(theme.colors.accent, lineWidth: theme.borderWidth.thin)
				}
			}
		}
		.disabled(isLoading)
		.accessibilityIdentifier(accessibilityIdentifier ?? "")
	}

	private var foregroundColor: Color {
		switch variant {
		case .primary:
			theme.colors.textInverted
		case .secondary, .tertiary:
			theme.colors.accent
		}
	}

	private var backgroundColor: Color {
		switch variant {
		case .primary:
			theme.colors.accent
		case .secondary:
			Color.clear
		case .tertiary:
			theme.colors.accentSubtle
		}
	}

	private var horizontalPadding: CGFloat {
		switch variant {
		case .primary:
			theme.spacing.lg
		case .secondary, .tertiary:
			theme.spacing.md
		}
	}

	private var verticalPadding: CGFloat {
		switch variant {
		case .primary:
			theme.spacing.md
		case .secondary, .tertiary:
			theme.spacing.sm
		}
	}
}

/*
// MARK: - Previews

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
*/
