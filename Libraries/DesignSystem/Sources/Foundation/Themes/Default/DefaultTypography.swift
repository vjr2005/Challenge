import SwiftUI

/// The default typography matching the original ``TextStyle`` font and color values.
public struct DefaultTypography: DSTypography {
	/// Creates a new default typography
	public init() {}

	public func font(for style: TextStyle) -> Font {
		switch style {
		case .largeTitle:
			.system(.largeTitle, design: .rounded, weight: .bold)
		case .title:
			.system(.title, design: .rounded, weight: .bold)
		case .title2:
			.system(.title2, design: .rounded, weight: .semibold)
		case .title3:
			.system(.title3, design: .rounded, weight: .semibold)
		case .headline:
			.system(.headline, design: .rounded, weight: .semibold)
		case .body:
			.system(.body, design: .rounded)
		case .subheadline:
			.system(.subheadline, design: .serif)
		case .footnote:
			.system(.footnote, design: .rounded)
		case .caption:
			.system(.caption, design: .rounded)
		case .caption2:
			.system(.caption2, design: .monospaced)
		}
	}

	public func defaultColor(for style: TextStyle, in palette: DSColorPalette) -> Color {
		switch style {
		case .largeTitle, .title, .title2, .title3, .headline, .body:
			palette.textPrimary
		case .subheadline, .footnote, .caption:
			palette.textSecondary
		case .caption2:
			palette.textTertiary
		}
	}
}
