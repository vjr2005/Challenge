import ChallengeCore
import SwiftUI

/// A view that asynchronously loads and displays an image with caching support.
public struct DSAsyncImage<Content: View>: View {
	private let url: URL?
	private let refreshID: UUID?
	private let content: (AsyncImagePhase) -> Content

	@Environment(\.imageLoader) private var imageLoader
	@State private var phase: AsyncImagePhase = .empty

	/// Creates a cached async image view with phase-based content.
	/// - Parameters:
	///   - url: The URL of the image to load.
	///   - refreshID: Optional identifier to force image reload. Change this value to re-fetch the image (e.g. after cache invalidation).
	///   - content: A closure that takes the current async image phase and returns a view.
	public init(
		url: URL?,
		refreshID: UUID? = nil,
		@ViewBuilder content: @escaping (AsyncImagePhase) -> Content
	) {
		self.url = url
		self.refreshID = refreshID
		self.content = content
	}

	public var body: some View {
		content(displayPhase)
			.accessibilityHidden(true)
			.task(id: TaskTrigger(url: url, refreshID: refreshID)) {
				phase = .empty
				await loadImage()
			}
	}
}

// MARK: - Default Content

public extension DSAsyncImage where Content == DSAsyncImageDefaultContentView {
	/// Creates a cached async image view with default content.
	/// - Parameters:
	///   - url: The URL of the image to load.
	///   - refreshID: Optional identifier to force image reload. Change this value to re-fetch the image (e.g. after cache invalidation).
	///   - failureImage: The system image name displayed when loading fails. Defaults to `"photo"`.
	///
	/// Default behavior:
	/// - **Success**: displays the image with `resizable()` and `scaledToFill()`
	/// - **Empty**: displays a `ProgressView`
	/// - **Failure**: displays a themed placeholder with the specified system image
	init(url: URL?, refreshID: UUID? = nil, failureImage: String = "photo") {
		self.url = url
		self.refreshID = refreshID
		self.content = { phase in
			DSAsyncImageDefaultContentView(phase: phase, failureImage: failureImage)
		}
	}
}

// MARK: - TaskTrigger

// Properties are read by synthesized Equatable (used as .task(id:) trigger),
// but Periphery cannot detect usage through synthesized conformances.
private struct TaskTrigger: Equatable {
	let url: URL? // periphery:ignore
	let refreshID: UUID? // periphery:ignore
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

/*
// MARK: - Previews

#Preview("DSAsyncImage") {
	VStack(spacing: DefaultSpacing().lg) {
		DSAsyncImage(url: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"))
			.frame(width: 100, height: 100)
			.clipShape(RoundedRectangle(cornerRadius: DefaultCornerRadius().md))

		DSAsyncImage(url: nil)
			.frame(width: 100, height: 100)
			.clipShape(RoundedRectangle(cornerRadius: DefaultCornerRadius().md))
	}
	.padding()
}
*/
