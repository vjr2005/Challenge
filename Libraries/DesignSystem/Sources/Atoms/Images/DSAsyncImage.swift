import ChallengeCore
import SwiftUI

/// A view that asynchronously loads and displays an image with caching support.
public struct DSAsyncImage<Content: View>: View {
	private let url: URL?
	private let accessibilitySuffix: String
	private let content: (AsyncImagePhase) -> Content

	@Environment(\.imageLoader) private var imageLoader
	@Environment(\.dsAccessibilityIdentifier) private var parentIdentifier
	@State private var phase: AsyncImagePhase = .empty

	/// Creates a cached async image view with phase-based content.
	/// - Parameters:
	///   - url: The URL of the image to load.
	///   - accessibilitySuffix: The suffix to append to the propagated accessibility identifier (default: "image")
	///   - content: A closure that takes the current async image phase and returns a view.
	public init(
		url: URL?,
		accessibilitySuffix: String = "image",
		@ViewBuilder content: @escaping (AsyncImagePhase) -> Content
	) {
		self.url = url
		self.accessibilitySuffix = accessibilitySuffix
		self.content = content
	}

	public var body: some View {
		content(displayPhase)
			.dsAccessibility(parentIdentifier: parentIdentifier, suffix: accessibilitySuffix, traits: .isImage)
			.accessibilityHidden(true)
			.task(id: url) {
				await loadImage()
			}
	}
}

// MARK: - Default Content

public extension DSAsyncImage where Content == AnyView {
	/// Creates a cached async image view with default content.
	/// - Parameters:
	///   - url: The URL of the image to load.
	///   - accessibilitySuffix: The suffix to append to the propagated accessibility identifier (default: "image")
	///
	/// Default behavior:
	/// - Success: displays the image with `resizable()` and `scaledToFill()`
	/// - Empty: displays a `ProgressView`
	/// - Failure: displays an error placeholder
	init(url: URL?, accessibilitySuffix: String = "image") {
		self.url = url
		self.accessibilitySuffix = accessibilitySuffix
		self.content = { phase in
			AnyView(DefaultPhaseContent(phase: phase))
		}
	}
}

// MARK: - DefaultPhaseContent

private struct DefaultPhaseContent: View {
	let phase: AsyncImagePhase

	var body: some View {
		switch phase {
		case .success(let image):
			image
				.resizable()
				.scaledToFill()
		case .empty:
			ProgressView()
		case .failure:
			ZStack {
				ColorToken.surfaceSecondary
				Image(systemName: "photo")
					.foregroundStyle(ColorToken.textTertiary)
			}
		@unknown default:
			ProgressView()
		}
	}
}

// MARK: - Private

private extension DSAsyncImage {
	var displayPhase: AsyncImagePhase {
		if case .success = phase {
			return phase
		}
		guard let url else {
			return phase
		}
		if let cachedImage = imageLoader.cachedImage(for: url) {
			return .success(Image(uiImage: cachedImage))
		}
		return phase
	}

	func loadImage() async {
		guard let url else {
			return
		}
		if imageLoader.cachedImage(for: url) != nil {
			return
		}
		if let image = await imageLoader.image(for: url) {
			phase = .success(Image(uiImage: image))
		} else if !Task.isCancelled {
			phase = .failure(URLError(.cannotLoadFromNetwork))
		}
	}
}
