import SwiftUI

/// An error view component with icon, message, and retry action.
public struct DSErrorView: View {
	private let title: String
	private let message: String?
	private let retryTitle: String?
	private let retryAction: (() -> Void)?
	private let accessibilityIdentifier: String?

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
		VStack(spacing: SpacingToken.lg) {
			Image(systemName: "exclamationmark.triangle.fill")
				.font(.system(size: IconSizeToken.xxl))
				.foregroundStyle(ColorToken.statusError)
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

			if let retryTitle, let retryAction {
				DSButton(
					retryTitle,
					icon: "arrow.clockwise",
					variant: .secondary,
					accessibilityIdentifier: accessibilityIdentifier.map { "\($0).retryButton" },
					action: retryAction
				)
			}
		}
		.padding(SpacingToken.xl)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

#Preview("DSErrorView") {
	VStack(spacing: SpacingToken.xxl) {
		DSErrorView(title: "Something went wrong")

		DSErrorView(
			title: "Connection Error",
			message: "Please check your internet connection and try again.",
			retryTitle: "Retry"
		) {}
	}
}
