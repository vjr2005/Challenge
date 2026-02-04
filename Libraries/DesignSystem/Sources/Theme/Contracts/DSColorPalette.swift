import SwiftUI

/// Contract for design system color palettes.
///
/// Conforming types provide semantic color values for all design system components.
/// Each property maps to a semantic purpose (background, text, status, etc.).
public protocol DSColorPalette: Sendable {
	// MARK: - Background Colors

	/// Primary background color
	var backgroundPrimary: Color { get }

	/// Secondary background color
	var backgroundSecondary: Color { get }

	/// Tertiary background color
	var backgroundTertiary: Color { get }

	// MARK: - Surface Colors

	/// Primary surface color for cards and elevated elements
	var surfacePrimary: Color { get }

	/// Secondary surface color
	var surfaceSecondary: Color { get }

	// MARK: - Text Colors

	/// Primary text color
	var textPrimary: Color { get }

	/// Secondary text color
	var textSecondary: Color { get }

	/// Tertiary text color
	var textTertiary: Color { get }

	/// Inverted text color for dark backgrounds
	var textInverted: Color { get }

	// MARK: - Status Colors

	/// Success status color
	var statusSuccess: Color { get }

	/// Error status color
	var statusError: Color { get }

	/// Warning status color
	var statusWarning: Color { get }

	/// Neutral/unknown status color
	var statusNeutral: Color { get }

	// MARK: - Interactive Colors

	/// Accent color for interactive elements
	var accent: Color { get }

	/// Subtle accent color for backgrounds
	var accentSubtle: Color { get }

	/// Disabled state color
	var disabled: Color { get }

	// MARK: - Separator Colors

	/// Standard separator color
	var separator: Color { get }

	/// Opaque separator color
	var separatorOpaque: Color { get }
}
