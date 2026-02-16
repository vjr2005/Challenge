import SwiftUI

/// A row card component that displays an image, text content, and optional status indicator.
///
/// This component propagates accessibility identifiers to its subviews
/// with descriptive suffixes (.image, .title, .subtitle, .caption, .status, .statusLabel).
public struct DSCardInfoRow: View {
	private let imageURL: URL?
	private let title: String
	private let subtitle: String?
	private let caption: String?
	private let captionIcon: String?
	private let status: DSStatus?
	private let statusLabel: String?
	private let accessibilityIdentifier: String?

	@Environment(\.dsTheme) private var theme

	/// Creates a DSCardInfoRow.
	/// - Parameters:
	///   - imageURL: The URL of the image to display.
	///   - title: The main title text.
	///   - subtitle: Optional subtitle text.
	///   - caption: Optional caption text displayed below the subtitle.
	///   - captionIcon: Optional SF Symbol name for the caption icon.
	///   - status: Optional status indicator to display.
	///   - statusLabel: Optional label displayed below the status indicator.
	///   - accessibilityIdentifier: Optional accessibility identifier for UI testing
	public init(
		imageURL: URL?,
		title: String,
		subtitle: String? = nil,
		caption: String? = nil,
		captionIcon: String? = nil,
		status: DSStatus? = nil,
		statusLabel: String? = nil,
		accessibilityIdentifier: String? = nil
	) {
		self.imageURL = imageURL
		self.title = title
		self.subtitle = subtitle
		self.caption = caption
		self.captionIcon = captionIcon
		self.status = status
		self.statusLabel = statusLabel
		self.accessibilityIdentifier = accessibilityIdentifier
	}

	public var body: some View {
		DSCard {
			HStack(spacing: theme.spacing.lg) {
				imageView
				textContent
				Spacer()
				if status != nil {
					statusView
				}
			}
		}
		.accessibilityIdentifier(accessibilityIdentifier ?? "")
	}
}

// MARK: - Subviews

private extension DSCardInfoRow {
	var imageView: some View {
		DSAsyncImage(url: imageURL)
			.frame(width: theme.dimensions.xxxl, height: theme.dimensions.xxxl)
			.clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.md))
			.accessibilityIdentifier(accessibilityIdentifier.map { "\($0).image" } ?? "")
	}

	var textContent: some View {
		VStack(alignment: .leading, spacing: theme.spacing.xs) {
			Text(title)
				.font(theme.typography.headline)
				.foregroundStyle(theme.colors.textPrimary)
				.accessibilityIdentifier(accessibilityIdentifier.map { "\($0).title" } ?? "")
				.lineLimit(1)

			if let subtitle {
				Text(subtitle)
					.font(theme.typography.subheadline)
					.foregroundStyle(theme.colors.textSecondary)
					.accessibilityIdentifier(accessibilityIdentifier.map { "\($0).subtitle" } ?? "")
			}

			if let caption {
				captionView(caption)
			}
		}
	}

	func captionView(_ text: String) -> some View {
		HStack(spacing: theme.spacing.xs) {
			if let captionIcon {
				Image(systemName: captionIcon)
					.font(.caption2)
					.accessibilityHidden(true)
			}
			Text(text)
				.font(theme.typography.caption2)
				.accessibilityIdentifier(accessibilityIdentifier.map { "\($0).caption" } ?? "")
		}
		.foregroundStyle(theme.colors.textTertiary)
		.lineLimit(1)
	}

	var statusView: some View {
		VStack(spacing: theme.spacing.xs) {
			if let status {
				DSStatusIndicator(
					status: status,
					accessibilityIdentifier: accessibilityIdentifier.map { "\($0).status" }
				)
			}

			if let statusLabel {
				Text(statusLabel)
					.font(theme.typography.caption)
					.foregroundStyle(theme.colors.textSecondary)
					.accessibilityIdentifier(accessibilityIdentifier.map { "\($0).statusLabel" } ?? "")
			}
		}
	}
}

/*
// MARK: - Preview

#Preview("DSCardInfoRow") {
	VStack(spacing: DefaultSpacing().lg) {
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
	.background(DefaultColorPalette().backgroundSecondary)
}
*/
