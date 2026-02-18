import SwiftUI

/// The default color palette matching the original ``ColorToken`` values.
struct DefaultColorPalette: DSColorPaletteContract {
	// MARK: - Background Colors

	var backgroundPrimary: Color { Color(.systemBackground) }
	var backgroundSecondary: Color { Color(.systemGroupedBackground) }
	var backgroundTertiary: Color { Color(.tertiarySystemBackground) }

	// MARK: - Surface Colors

	var surfacePrimary: Color { Color(.secondarySystemBackground) }
	var surfaceSecondary: Color { Color(.tertiarySystemGroupedBackground) }

	// MARK: - Text Colors

	var textPrimary: Color { Color(.label) }
	var textSecondary: Color { Color(.secondaryLabel) }
	var textTertiary: Color { Color(.tertiaryLabel) }
	var textInverted: Color { Color(.systemBackground) }

	// MARK: - Status Colors

	var statusSuccess: Color { .green }
	var statusError: Color { .red }
	var statusWarning: Color { .orange }
	var statusNeutral: Color { .gray }

	// MARK: - Interactive Colors

	var accent: Color { Color(red: 0x33 / 255.0, green: 0x38 / 255.0, blue: 0x44 / 255.0) }
	var accentSubtle: Color { accent.opacity(0.1) }
	var disabled: Color { Color(.systemGray3) }

	// MARK: - Separator Colors

	var separator: Color { Color(.separator) }
	var separatorOpaque: Color { Color(.opaqueSeparator) }
}
