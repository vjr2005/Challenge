import SwiftUI

/// An empty state view component with icon, title, message, and optional action.
public struct DSEmptyState: View {
	private let icon: String
	private let title: String
	private let message: String?
	private let actionTitle: String?
	private let action: (() -> Void)?
	private let accessibilityIdentifier: String?

	@Environment(\.dsTheme) private var theme

	/// Creates a DSEmptyState.
	/// - Parameters:
	///   - icon: SF Symbol name for the icon
	///   - title: The title text
	///   - message: Optional description message
	///   - actionTitle: Optional action button title
	///   - action: Optional action to perform
	///   - accessibilityIdentifier: Optional accessibility identifier for UI testing
	public init(
		icon: String,
		title: String,
		message: String? = nil,
		actionTitle: String? = nil,
		action: (() -> Void)? = nil,
		accessibilityIdentifier: String? = nil
	) {
		self.icon = icon
		self.title = title
		self.message = message
		self.actionTitle = actionTitle
		self.action = action
		self.accessibilityIdentifier = accessibilityIdentifier
	}

	public var body: some View {
		VStack(spacing: theme.spacing.lg) {
			Image(systemName: icon)
				.font(.system(size: IconSizeToken.xxxl))
				.foregroundStyle(theme.colors.textTertiary)
				.accessibilityIdentifier(accessibilityIdentifier.map { "\($0).icon" } ?? "")
				.accessibilityHidden(true)

			VStack(spacing: theme.spacing.sm) {
				Text(title)
					.font(theme.typography.font(for: .headline))
					.foregroundStyle(theme.colors.textPrimary)
					.accessibilityIdentifier(accessibilityIdentifier.map { "\($0).title" } ?? "")

				if let message {
					Text(message)
						.font(theme.typography.font(for: .body))
						.foregroundStyle(theme.colors.textSecondary)
						.accessibilityIdentifier(accessibilityIdentifier.map { "\($0).message" } ?? "")
						.multilineTextAlignment(.center)
				}
			}

			if let actionTitle, let action {
				DSButton(
					actionTitle,
					variant: .secondary,
					accessibilityIdentifier: accessibilityIdentifier.map { "\($0).button" },
					action: action
				)
			}
		}
		.padding(theme.spacing.xl)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

/*
// MARK: - Previews

#Preview("DSEmptyState") {
	VStack(spacing: SpacingToken.xxl) {
		DSEmptyState(
			icon: "magnifyingglass",
			title: "No Results"
		)

		DSEmptyState(
			icon: "tray",
			title: "No Characters",
			message: "There are no characters to display at this time.",
			actionTitle: "Refresh"
		) {}
	}
}
*/
