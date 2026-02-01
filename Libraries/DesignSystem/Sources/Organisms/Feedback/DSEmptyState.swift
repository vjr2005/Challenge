import SwiftUI

/// An empty state view component with icon, title, message, and optional action.
public struct DSEmptyState: View {
	private let icon: String
	private let title: String
	private let message: String?
	private let actionTitle: String?
	private let action: (() -> Void)?
	private let accessibilityIdentifier: String?

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
		VStack(spacing: SpacingToken.lg) {
			Image(systemName: icon)
				.font(.system(size: IconSizeToken.xxxl))
				.foregroundStyle(ColorToken.textTertiary)
				.accessibilityIdentifier(accessibilityIdentifier.map { "\($0).icon" } ?? "")
				.accessibilityHidden(true)

			VStack(spacing: SpacingToken.sm) {
				Text(title)
					.font(TextStyle.headline.font)
					.foregroundStyle(ColorToken.textPrimary)
					.accessibilityIdentifier(accessibilityIdentifier.map { "\($0).title" } ?? "")

				if let message {
					Text(message)
						.font(TextStyle.body.font)
						.foregroundStyle(ColorToken.textSecondary)
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
		.padding(SpacingToken.xl)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

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
