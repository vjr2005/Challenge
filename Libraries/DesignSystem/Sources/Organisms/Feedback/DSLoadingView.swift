import SwiftUI

/// A loading view component with progress indicator and optional message.
public struct DSLoadingView: View {
	private let message: String?

	@Environment(\.dsAccessibilityIdentifier) private var parentIdentifier

	/// Creates a DSLoadingView.
	/// - Parameter message: Optional loading message
	public init(message: String? = nil) {
		self.message = message
	}

	public var body: some View {
		VStack(spacing: SpacingToken.lg) {
			ProgressView()
				.scaleEffect(1.5)
				.dsAccessibility(parentIdentifier: parentIdentifier, suffix: "indicator")

			if let message {
				DSText(message, style: .body, color: ColorToken.textSecondary, accessibilitySuffix: "message")
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
