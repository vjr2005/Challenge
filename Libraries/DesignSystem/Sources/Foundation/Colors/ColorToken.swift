import SwiftUI

/// Design tokens for colors following semantic naming.
public enum ColorToken {
	// MARK: - Background Colors

	/// Primary background color (systemBackground)
	public static var backgroundPrimary: Color { Color(.systemBackground) }

	/// Secondary background color (systemGroupedBackground)
	public static var backgroundSecondary: Color { Color(.systemGroupedBackground) }

	/// Tertiary background color (tertiarySystemBackground)
	public static var backgroundTertiary: Color { Color(.tertiarySystemBackground) }

	// MARK: - Surface Colors

	/// Primary surface color for cards and elevated elements
	public static var surfacePrimary: Color { Color(.secondarySystemBackground) }

	/// Secondary surface color
	public static var surfaceSecondary: Color { Color(.tertiarySystemGroupedBackground) }

	// MARK: - Text Colors

	/// Primary text color (label)
	public static var textPrimary: Color { Color(.label) }

	/// Secondary text color (secondaryLabel)
	public static var textSecondary: Color { Color(.secondaryLabel) }

	/// Tertiary text color (tertiaryLabel)
	public static var textTertiary: Color { Color(.tertiaryLabel) }

	/// Inverted text color for dark backgrounds
	public static var textInverted: Color { Color(.systemBackground) }

	// MARK: - Status Colors

	/// Success status color (green)
	public static var statusSuccess: Color { .green }

	/// Error status color (red)
	public static var statusError: Color { .red }

	/// Warning status color (orange)
	public static var statusWarning: Color { .orange }

	/// Neutral/unknown status color (gray)
	public static var statusNeutral: Color { .gray }

	// MARK: - Interactive Colors

	/// Accent color for interactive elements
	public static var accent: Color { .accentColor }

	/// Subtle accent color for backgrounds
	public static var accentSubtle: Color { .accentColor.opacity(0.1) }

	/// Disabled state color
	public static var disabled: Color { Color(.systemGray3) }

	// MARK: - Separator Colors

	/// Standard separator color
	public static var separator: Color { Color(.separator) }

	/// Opaque separator color
	public static var separatorOpaque: Color { Color(.opaqueSeparator) }
}
