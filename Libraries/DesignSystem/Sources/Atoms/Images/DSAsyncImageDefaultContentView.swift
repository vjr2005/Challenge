import SwiftUI

/// Default content view for ``DSAsyncImage`` that renders each loading phase.
///
/// This view is used automatically when creating a `DSAsyncImage` without a custom
/// `content` closure. It provides themed visuals for each ``AsyncImagePhase``:
///
/// - **Success**: the loaded image, displayed with `resizable()` and `scaledToFill()`.
/// - **Empty**: a `ProgressView` spinner indicating the image is loading.
/// - **Failure**: a themed placeholder background with a system image icon.
///
/// The failure icon can be customized via the `failureImage` parameter.
public struct DSAsyncImageDefaultContentView: View {
	/// The current loading phase of the async image.
	let phase: AsyncImagePhase

	/// The SF Symbol name displayed when the image fails to load.
	let failureImage: String

	@Environment(\.dsTheme) private var theme

	public var body: some View {
		switch phase {
		case .success(let image):
			image
				.resizable()
				.scaledToFill()
		case .empty:
			ProgressView()
		case .failure:
			ZStack {
				theme.colors.surfaceSecondary
				Image(systemName: failureImage)
					.foregroundStyle(theme.colors.textTertiary)
			}
		@unknown default:
			ProgressView()
		}
	}
}
