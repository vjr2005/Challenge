import SwiftUI

/// An error view component with icon, message, and retry action.
public struct DSErrorView: View {
	private let title: String
	private let message: String?
	private let retryTitle: String?
	private let retryAction: (() -> Void)?

	/// Creates a DSErrorView.
	/// - Parameters:
	///   - title: The error title
	///   - message: Optional error message
	///   - retryTitle: Optional retry button title
	///   - retryAction: Optional retry action
	public init(
		title: String,
		message: String? = nil,
		retryTitle: String? = nil,
		retryAction: (() -> Void)? = nil
	) {
		self.title = title
		self.message = message
		self.retryTitle = retryTitle
		self.retryAction = retryAction
	}

	public var body: some View {
		VStack(spacing: SpacingToken.lg) {
			Image(systemName: "exclamationmark.triangle.fill")
				.font(.system(size: IconSizeToken.xxl))
				.foregroundStyle(ColorToken.statusError)

			VStack(spacing: SpacingToken.sm) {
				DSText(title, style: .headline)

				if let message {
					DSText(message, style: .body, color: ColorToken.textSecondary)
						.multilineTextAlignment(.center)
				}
			}

			if let retryTitle, let retryAction {
				DSButton(retryTitle, icon: "arrow.clockwise", variant: .secondary, action: retryAction)
			}
		}
		.padding(SpacingToken.xl)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

#if DEBUG
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
#endif
