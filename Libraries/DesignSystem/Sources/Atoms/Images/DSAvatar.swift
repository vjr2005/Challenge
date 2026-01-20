import SwiftUI

/// Size options for avatars.
public enum DSAvatarSize {
	/// Small avatar (32pt)
	case small

	/// Medium avatar (48pt)
	case medium

	/// Large avatar (64pt)
	case large

	/// Extra large avatar (80pt)
	case extraLarge

	/// Custom size
	case custom(CGFloat)

	/// The dimension value for this size
	public var dimension: CGFloat {
		switch self {
		case .small:
			32
		case .medium:
			48
		case .large:
			64
		case .extraLarge:
			80
		case .custom(let size):
			size
		}
	}
}

/// An avatar component that displays an image with optional placeholder.
public struct DSAvatar<Content: View, Placeholder: View>: View {
	private let size: DSAvatarSize
	private let content: Content
	private let placeholder: Placeholder

	/// Creates a DSAvatar with custom content and placeholder.
	/// - Parameters:
	///   - size: The avatar size
	///   - content: The content view builder
	///   - placeholder: The placeholder view builder
	public init(
		size: DSAvatarSize = .medium,
		@ViewBuilder content: () -> Content,
		@ViewBuilder placeholder: () -> Placeholder
	) {
		self.size = size
		self.content = content()
		self.placeholder = placeholder()
	}

	public var body: some View {
		content
			.frame(width: size.dimension, height: size.dimension)
			.clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.md))
			.overlay {
				RoundedRectangle(cornerRadius: CornerRadiusToken.md)
					.stroke(ColorToken.separator, lineWidth: 0.5)
			}
	}
}

public extension DSAvatar where Content == EmptyView {
	/// Creates a DSAvatar with only a placeholder.
	/// - Parameters:
	///   - size: The avatar size
	///   - placeholder: The placeholder view builder
	init(
		size: DSAvatarSize = .medium,
		@ViewBuilder placeholder: () -> Placeholder
	) {
		self.size = size
		self.content = EmptyView()
		self.placeholder = placeholder()
	}
}

/// A convenience avatar that displays an async image from a URL.
public struct DSAsyncAvatar: View {
	private let url: URL?
	private let size: DSAvatarSize

	/// Creates a DSAsyncAvatar.
	/// - Parameters:
	///   - url: The image URL
	///   - size: The avatar size
	public init(url: URL?, size: DSAvatarSize = .medium) {
		self.url = url
		self.size = size
	}

	public var body: some View {
		DSAvatar(size: size) {
			AsyncImage(url: url) { phase in
				switch phase {
				case .success(let image):
					image
						.resizable()
						.aspectRatio(contentMode: .fill)
				case .failure:
					placeholderView
				case .empty:
					ProgressView()
				@unknown default:
					placeholderView
				}
			}
		} placeholder: {
			placeholderView
		}
	}

	private var placeholderView: some View {
		ZStack {
			ColorToken.surfaceSecondary
			Image(systemName: "person.fill")
				.font(.system(size: size.dimension * 0.4))
				.foregroundStyle(ColorToken.textTertiary)
		}
	}
}

#if DEBUG
#Preview("DSAvatar Sizes") {
	HStack(spacing: SpacingToken.lg) {
		DSAsyncAvatar(url: nil, size: .small)
		DSAsyncAvatar(url: nil, size: .medium)
		DSAsyncAvatar(url: nil, size: .large)
		DSAsyncAvatar(url: nil, size: .extraLarge)
	}
	.padding()
}

#Preview("DSAvatar with Image") {
	DSAsyncAvatar(
		url: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"),
		size: .large
	)
	.padding()
}
#endif
