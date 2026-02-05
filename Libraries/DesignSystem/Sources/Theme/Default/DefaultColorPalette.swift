import SwiftUI

/// The default color palette matching the original ``ColorToken`` values.
public struct DefaultColorPalette: DSColorPaletteContract {
	/// Creates a new default color palette
	public init() {}

	// MARK: - Background Colors

	public var backgroundPrimary: Color { Color(.systemBackground) }
	public var backgroundSecondary: Color { Color(.systemGroupedBackground) }
	public var backgroundTertiary: Color { Color(.tertiarySystemBackground) }

	// MARK: - Surface Colors

	public var surfacePrimary: Color { Color(.secondarySystemBackground) }
	public var surfaceSecondary: Color { Color(.tertiarySystemGroupedBackground) }

	// MARK: - Text Colors

	public var textPrimary: Color { Color(.label) }
	public var textSecondary: Color { Color(.secondaryLabel) }
	public var textTertiary: Color { Color(.tertiaryLabel) }
	public var textInverted: Color { Color(.systemBackground) }

	// MARK: - Status Colors

	public var statusSuccess: Color { .green }
	public var statusError: Color { .red }
	public var statusWarning: Color { .orange }
	public var statusNeutral: Color { .gray }

	// MARK: - Interactive Colors

	public var accent: Color { Color(red: 0x33 / 255.0, green: 0x38 / 255.0, blue: 0x44 / 255.0) }
	public var accentSubtle: Color { accent.opacity(0.1) }
	public var disabled: Color { Color(.systemGray3) }

	// MARK: - Separator Colors

	public var separator: Color { Color(.separator) }
	public var separatorOpaque: Color { Color(.opaqueSeparator) }
}
