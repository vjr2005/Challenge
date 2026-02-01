import SwiftUI

/// An info row component that displays icon + label + value.
public struct DSInfoRow: View {
	private let icon: String
	private let label: String
	private let value: String
	private let iconColor: Color
	private let accessibilityIdentifier: String?

	/// Creates a DSInfoRow.
	/// - Parameters:
	///   - icon: SF Symbol name for the icon
	///   - label: The label text
	///   - value: The value text
	///   - iconColor: The icon color (default: accent)
	///   - accessibilityIdentifier: Optional accessibility identifier for UI testing
	public init(
		icon: String,
		label: String,
		value: String,
		iconColor: Color = ColorToken.accent,
		accessibilityIdentifier: String? = nil
	) {
		self.icon = icon
		self.label = label
		self.value = value
		self.iconColor = iconColor
		self.accessibilityIdentifier = accessibilityIdentifier
	}

	public var body: some View {
		HStack(spacing: SpacingToken.md) {
			Image(systemName: icon)
				.font(TextStyle.body.font)
				.foregroundStyle(iconColor)
				.frame(width: SpacingToken.xxl)
				.accessibilityIdentifier(accessibilityIdentifier.map { "\($0).icon" } ?? "")
				.accessibilityHidden(true)

			VStack(alignment: .leading, spacing: SpacingToken.xxs) {
				Text(label)
					.font(TextStyle.caption.font)
					.foregroundStyle(ColorToken.textSecondary)
					.accessibilityIdentifier(accessibilityIdentifier.map { "\($0).label" } ?? "")
				Text(value)
					.font(TextStyle.body.font)
					.foregroundStyle(ColorToken.textPrimary)
					.accessibilityIdentifier(accessibilityIdentifier.map { "\($0).value" } ?? "")
			}

			Spacer()
		}
	}
}

/*
// MARK: - Previews

#Preview("DSInfoRow") {
	VStack(spacing: SpacingToken.md) {
		DSInfoRow(icon: "person.fill", label: "Name", value: "Rick Sanchez")
		DSInfoRow(icon: "location.fill", label: "Location", value: "Citadel of Ricks")
		DSInfoRow(icon: "globe", label: "Origin", value: "Earth (C-137)")
		DSInfoRow(
			icon: "heart.fill",
			label: "Status",
			value: "Alive",
			iconColor: ColorToken.statusSuccess
		)
	}
	.padding()
}
*/
