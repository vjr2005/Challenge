import SwiftUI

/// An error view component with icon, message, and retry action.
public struct DSErrorView: View {
	private let title: String
	private let message: String?
	private let retryTitle: String?
	private let retryAction: (() -> Void)?
	private let accessibilityIdentifier: String?

	@Environment(\.dsTheme) private var theme

	/// Creates a DSErrorView.
	/// - Parameters:
	///   - title: The error title
	///   - message: Optional error message
	///   - retryTitle: Optional retry button title
	///   - retryAction: Optional retry action
	///   - accessibilityIdentifier: Optional accessibility identifier for UI testing
	public init(
		title: String,
		message: String? = nil,
		retryTitle: String? = nil,
		retryAction: (() -> Void)? = nil,
		accessibilityIdentifier: String? = nil
	) {
		self.title = title
		self.message = message
		self.retryTitle = retryTitle
		self.retryAction = retryAction
		self.accessibilityIdentifier = accessibilityIdentifier
	}

	public var body: some View {
		VStack(spacing: theme.spacing.lg) {
			Image(systemName: "exclamationmark.triangle.fill")
				.font(.system(size: theme.dimensions.xxl))
				.foregroundStyle(theme.colors.statusError)
				.accessibilityIdentifier(accessibilityIdentifier.map { "\($0).icon" } ?? "")
				.accessibilityHidden(true)

			VStack(spacing: theme.spacing.sm) {
				Text(title)
					.font(theme.typography.headline)
					.foregroundStyle(theme.colors.textPrimary)
					.accessibilityIdentifier(accessibilityIdentifier.map { "\($0).title" } ?? "")

				if let message {
					Text(message)
						.font(theme.typography.body)
						.foregroundStyle(theme.colors.textSecondary)
						.accessibilityIdentifier(accessibilityIdentifier.map { "\($0).message" } ?? "")
						.multilineTextAlignment(.center)
				}
			}

			if let retryTitle, let retryAction {
				DSButton(
					retryTitle,
					icon: "arrow.clockwise",
					variant: .secondary,
					accessibilityIdentifier: accessibilityIdentifier.map { "\($0).button" },
					action: retryAction
				)
			}
		}
		.padding(theme.spacing.xl)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

/*
// MARK: - Previews

#Preview("DSErrorView") {
	VStack(spacing: DefaultSpacing().xxl) {
		DSErrorView(title: "Something went wrong")

		DSErrorView(
			title: "Connection Error",
			message: "Please check your internet connection and try again.",
			retryTitle: "Retry"
		) {}
	}
}
*/
