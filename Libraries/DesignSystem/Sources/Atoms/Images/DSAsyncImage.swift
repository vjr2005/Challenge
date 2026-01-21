import ChallengeCore
import SwiftUI

/// A view that asynchronously loads and displays an image with caching support.
public struct DSAsyncImage<Content: View, Placeholder: View>: View {
	private let url: URL?
	private let content: (Image) -> Content
	private let placeholder: () -> Placeholder

	@Environment(\.imageLoader) private var imageLoader
	@State private var loadedImage: UIImage?

	/// Creates a cached async image view.
	/// - Parameters:
	///   - url: The URL of the image to load.
	///   - content: A closure that takes the loaded image and returns a view.
	///   - placeholder: A closure that returns a view to display while loading.
	public init(
		url: URL?,
		@ViewBuilder content: @escaping (Image) -> Content,
		@ViewBuilder placeholder: @escaping () -> Placeholder
	) {
		self.url = url
		self.content = content
		self.placeholder = placeholder
	}

	public var body: some View {
		Group {
			if let displayImage {
				content(Image(uiImage: displayImage))
			} else {
				placeholder()
			}
		}
		.task(id: url) {
			await loadImage()
		}
	}

	private var displayImage: UIImage? {
		if let loadedImage {
			return loadedImage
		}
		guard let url else {
			return nil
		}
		return imageLoader.cachedImage(for: url)
	}
}

private extension DSAsyncImage {
	func loadImage() async {
		guard let url else {
			return
		}
		loadedImage = await imageLoader.image(for: url)
	}
}
