import SwiftUI

/// A list item card with leading content, info, and optional trailing content.
public struct DSListItemCard<Leading: View, Trailing: View>: View {
	private let title: String
	private let subtitle: String?
	private let caption: String?
	private let leading: Leading
	private let trailing: Trailing

	/// Creates a DSListItemCard with custom leading and trailing content.
	/// - Parameters:
	///   - title: The main title text
	///   - subtitle: Optional subtitle text
	///   - caption: Optional caption text
	///   - leading: The leading content builder
	///   - trailing: The trailing content builder
	public init(
		title: String,
		subtitle: String? = nil,
		caption: String? = nil,
		@ViewBuilder leading: () -> Leading,
		@ViewBuilder trailing: () -> Trailing
	) {
		self.title = title
		self.subtitle = subtitle
		self.caption = caption
		self.leading = leading()
		self.trailing = trailing()
	}

	public var body: some View {
		DSCard(padding: SpacingToken.md) {
			HStack(spacing: SpacingToken.md) {
				leading

				VStack(alignment: .leading, spacing: SpacingToken.xxs) {
					DSText(title, style: .headline)

					if let subtitle {
						DSText(subtitle, style: .subheadline)
					}

					if let caption {
						DSText(caption, style: .caption)
					}
				}

				Spacer()

				trailing
			}
		}
	}
}

public extension DSListItemCard where Trailing == EmptyView {
	/// Creates a DSListItemCard without trailing content.
	init(
		title: String,
		subtitle: String? = nil,
		caption: String? = nil,
		@ViewBuilder leading: () -> Leading
	) {
		self.title = title
		self.subtitle = subtitle
		self.caption = caption
		self.leading = leading()
		self.trailing = EmptyView()
	}
}

public extension DSListItemCard where Leading == EmptyView {
	/// Creates a DSListItemCard without leading content.
	init(
		title: String,
		subtitle: String? = nil,
		caption: String? = nil,
		@ViewBuilder trailing: () -> Trailing
	) {
		self.title = title
		self.subtitle = subtitle
		self.caption = caption
		self.leading = EmptyView()
		self.trailing = trailing()
	}
}

public extension DSListItemCard where Leading == EmptyView, Trailing == EmptyView {
	/// Creates a DSListItemCard with only text content.
	init(
		title: String,
		subtitle: String? = nil,
		caption: String? = nil
	) {
		self.title = title
		self.subtitle = subtitle
		self.caption = caption
		self.leading = EmptyView()
		self.trailing = EmptyView()
	}
}

#if DEBUG
#Preview("DSListItemCard") {
	VStack(spacing: SpacingToken.md) {
		DSListItemCard(
			title: "Rick Sanchez",
			subtitle: "Human",
			caption: "Earth (C-137)",
			leading: {
				DSAsyncAvatar(url: nil, size: .medium)
			},
			trailing: {
				DSStatusBadge(status: .alive)
			}
		)

		DSListItemCard<DSAsyncAvatar, EmptyView>(
			title: "Morty Smith",
			subtitle: "Human",
			leading: {
				DSAsyncAvatar(url: nil, size: .medium)
			}
		)

		DSListItemCard<EmptyView, EmptyView>(
			title: "Simple Card",
			subtitle: "With subtitle only"
		)
	}
	.padding()
	.background(ColorToken.backgroundSecondary)
}
#endif
