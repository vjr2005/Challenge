import SwiftUI

/// Design tokens for text styles.
public enum TextStyle {
	/// Large title style - .rounded, .bold
	case largeTitle

	/// Title style - .rounded, .bold
	case title

	/// Title 2 style - .rounded, .semibold
	case title2

	/// Title 3 style - .rounded, .semibold
	case title3

	/// Headline style - .rounded, .semibold
	case headline

	/// Body style - .rounded
	case body

	/// Subheadline style - .serif
	case subheadline

	/// Footnote style - .rounded
	case footnote

	/// Caption style - .rounded
	case caption

	/// Caption 2 style - .monospaced
	case caption2

	/// The SwiftUI font for this text style
	public var font: Font {
		switch self {
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

	/// The default foreground color for this text style
	public var defaultColor: Color {
		switch self {
		case .largeTitle, .title, .title2, .title3, .headline, .body:
			ColorToken.textPrimary
		case .subheadline, .footnote, .caption:
			ColorToken.textSecondary
		case .caption2:
			ColorToken.textTertiary
		}
	}
}
