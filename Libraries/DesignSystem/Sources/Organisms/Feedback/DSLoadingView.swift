import SwiftUI

/// A loading view component with progress indicator and optional message.
public struct DSLoadingView: View {
	private let message: String?
	private let accessibilityIdentifier: String?

	/// Creates a DSLoadingView.
	/// - Parameters:
	///   - message: Optional loading message
	///   - accessibilityIdentifier: Optional accessibility identifier for UI testing
	public init(
		message: String? = nil,
		accessibilityIdentifier: String? = nil
	) {
		self.message = message
		self.accessibilityIdentifier = accessibilityIdentifier
	}

	public var body: some View {
		VStack(spacing: SpacingToken.lg) {
			ProgressView()
				.scaleEffect(1.5)
				.accessibilityIdentifier(accessibilityIdentifier.map { "\($0).indicator" } ?? "")

			if let message {
				DSText(
					message,
					style: .body,
					color: ColorToken.textSecondary,
					accessibilityIdentifier: accessibilityIdentifier.map { "\($0).message" }
				)
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

#Preview("DSLoadingView") {
	VStack(spacing: SpacingToken.xxl) {
		DSLoadingView()
			.frame(height: 100)

		DSLoadingView(message: "Loading characters...")
			.frame(height: 100)
	}
}
