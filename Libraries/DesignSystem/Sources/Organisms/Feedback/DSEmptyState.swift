import SwiftUI

/// An empty state view component with icon, title, message, and optional action.
public struct DSEmptyState: View {
	private let icon: String
	private let title: String
	private let message: String?
	private let actionTitle: String?
	private let action: (() -> Void)?

	/// Creates a DSEmptyState.
	/// - Parameters:
	///   - icon: SF Symbol name for the icon
	///   - title: The title text
	///   - message: Optional description message
	///   - actionTitle: Optional action button title
	///   - action: Optional action to perform
	public init(
		icon: String,
		title: String,
		message: String? = nil,
		actionTitle: String? = nil,
		action: (() -> Void)? = nil
	) {
		self.icon = icon
		self.title = title
		self.message = message
		self.actionTitle = actionTitle
		self.action = action
	}

	public var body: some View {
		VStack(spacing: SpacingToken.lg) {
			Image(systemName: icon)
				.font(.system(size: 56))
				.foregroundStyle(ColorToken.textTertiary)

			VStack(spacing: SpacingToken.sm) {
				DSText(title, style: .headline)

				if let message {
					DSText(message, style: .body, color: ColorToken.textSecondary)
						.multilineTextAlignment(.center)
				}
			}

			if let actionTitle, let action {
				DSButton(actionTitle, variant: .secondary, action: action)
			}
		}
		.padding(SpacingToken.xl)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

#if DEBUG
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
			actionTitle: "Refresh",
        ) {}
	}
}
#endif
