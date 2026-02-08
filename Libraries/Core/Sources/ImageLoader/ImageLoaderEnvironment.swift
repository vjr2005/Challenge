import SwiftUI

/// Environment key for providing an image loader.
private struct ImageLoaderKey: EnvironmentKey {
	static let defaultValue: any ImageLoaderContract = CachedImageLoader()
}

public extension EnvironmentValues {
	/// The image loader used by DSAsyncImage views.
	var imageLoader: any ImageLoaderContract {
		get { self[ImageLoaderKey.self] }
		set { self[ImageLoaderKey.self] = newValue }
	}
}

public extension View {
	/// Sets the image loader for this view and its descendants.
	/// - Parameter loader: The image loader to use.
	/// - Returns: A view with the image loader set in its environment.
	func imageLoader(_ loader: any ImageLoaderContract) -> some View {
		environment(\.imageLoader, loader)
	}
}
