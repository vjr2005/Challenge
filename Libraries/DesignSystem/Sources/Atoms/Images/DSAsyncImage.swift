import ChallengeCore
import SwiftUI

/// A view that asynchronously loads and displays an image with caching support.
public struct DSAsyncImage<Content: View>: View {
	private let url: URL?
	private let content: (AsyncImagePhase) -> Content

	@Environment(\.imageLoader) private var imageLoader
	@State private var phase: AsyncImagePhase = .empty

	/// Creates a cached async image view with phase-based content.
	/// - Parameters:
	///   - url: The URL of the image to load.
	///   - content: A closure that takes the current async image phase and returns a view.
	public init(
		url: URL?,
		@ViewBuilder content: @escaping (AsyncImagePhase) -> Content
	) {
		self.url = url
		self.content = content
	}

	public var body: some View {
		content(displayPhase)
			.task(id: url) {
				await loadImage()
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
