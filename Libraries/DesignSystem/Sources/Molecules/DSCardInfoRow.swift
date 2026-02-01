import SwiftUI

/// A row card component that displays an image, text content, and optional status indicator.
///
/// This component automatically propagates accessibility identifiers to its subviews
/// with descriptive suffixes (.image, .title, .subtitle, .caption, .status).
public struct DSCardInfoRow: View {
	private let imageURL: URL?
	private let title: String
	private let subtitle: String?
	private let caption: String?
	private let captionIcon: String?
	private let status: DSStatus?
	private let statusLabel: String?

	@Environment(\.dsAccessibilityIdentifier) private var parentIdentifier

	/// Creates a DSCardInfoRow.
	/// - Parameters:
	///   - imageURL: The URL of the image to display.
	///   - title: The main title text.
	///   - subtitle: Optional subtitle text.
	///   - caption: Optional caption text displayed below the subtitle.
	///   - captionIcon: Optional SF Symbol name for the caption icon.
	///   - status: Optional status indicator to display.
	///   - statusLabel: Optional label displayed below the status indicator.
	public init(
		imageURL: URL?,
		title: String,
		subtitle: String? = nil,
		caption: String? = nil,
		captionIcon: String? = nil,
		status: DSStatus? = nil,
		statusLabel: String? = nil
	) {
		self.imageURL = imageURL
		self.title = title
		self.subtitle = subtitle
		self.caption = caption
		self.captionIcon = captionIcon
		self.status = status
		self.statusLabel = statusLabel
	}

	public var body: some View {
		DSCard(padding: SpacingToken.lg) {
			HStack(spacing: SpacingToken.lg) {
				imageView
				textContent
				Spacer()
				if status != nil {
					statusView
				}
			}
		}
	}
}

// MARK: - Subviews

private extension DSCardInfoRow {
	var imageView: some View {
		DSAsyncImage(url: imageURL)
			.frame(width: 70, height: 70)
			.clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.md))
	}

	var textContent: some View {
		VStack(alignment: .leading, spacing: SpacingToken.xs) {
			DSText(title, style: .headline, accessibilitySuffix: "title")
				.lineLimit(1)

			if let subtitle {
				Text(subtitle)
					.font(TextStyle.subheadline.font)
					.foregroundStyle(ColorToken.textSecondary)
			}

			if let caption {
				captionView(caption)
			}
		}
	}

	func captionView(_ text: String) -> some View {
		HStack(spacing: SpacingToken.xs) {
			if let captionIcon {
				Image(systemName: captionIcon)
					.font(.caption2)
					.accessibilityHidden(true)
			}
			Text(text)
				.font(TextStyle.caption2.font)
		}
		.foregroundStyle(ColorToken.textTertiary)
		.lineLimit(1)
	}

	var statusView: some View {
		VStack(spacing: SpacingToken.xs) {
			if let status {
				DSStatusIndicator(status: status)
			}

			if let statusLabel {
				Text(statusLabel)
					.font(TextStyle.caption.font)
					.foregroundStyle(ColorToken.textSecondary)
			}
		}
	}
}

// MARK: - Preview

#Preview("DSCardInfoRow") {
	VStack(spacing: SpacingToken.lg) {
		DSCardInfoRow(
			imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"),
			title: "Rick Sanchez",
			subtitle: "Human",
			caption: "Citadel of Ricks",
			captionIcon: "mappin.circle.fill",
			status: .alive,
			statusLabel: "Alive"
		)

		DSCardInfoRow(
			imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/2.jpeg"),
			title: "Morty Smith",
			subtitle: "Human",
			status: .alive
		)

		DSCardInfoRow(
			imageURL: nil,
			title: "Unknown Character",
			subtitle: "Unknown species"
		)
	}
	.padding()
	.background(ColorToken.backgroundSecondary)
}
