import SwiftUI

/// Status types for the status indicator.
public enum DSStatus: String, CaseIterable, Sendable {
	/// Alive/active/success status
	case alive

	/// Dead/inactive/error status
	case dead

	/// Unknown/neutral status
	case unknown

	/// Returns the color for this status in the given palette.
	/// - Parameter palette: The color palette to use
	/// - Returns: The color associated with this status
	public func color(in palette: DSColorPaletteContract) -> Color {
		switch self {
		case .alive:
			palette.statusSuccess
		case .dead:
			palette.statusError
		case .unknown:
			palette.statusNeutral
		}
	}

	/// Creates a DSStatus from a string value (case-insensitive).
	/// - Parameter value: The string to convert
	/// - Returns: The matching status, or .unknown if not found
	public static func from(_ value: String) -> Self {
		Self(rawValue: value.lowercased()) ?? .unknown
	}
}

/// A status indicator component that displays a colored circle.
public struct DSStatusIndicator: View {
	private let status: DSStatus
	private let size: CGFloat?
	private let accessibilityIdentifier: String?

	@Environment(\.dsTheme) private var theme

	/// Creates a DSStatusIndicator.
	/// - Parameters:
	///   - status: The status to display
	///   - size: The size of the indicator (default: theme.dimensions.sm)
	///   - accessibilityIdentifier: Optional accessibility identifier for UI testing
	public init(
		status: DSStatus,
		size: CGFloat? = nil,
		accessibilityIdentifier: String? = nil
	) {
		self.status = status
		self.size = size
		self.accessibilityIdentifier = accessibilityIdentifier
	}

	public var body: some View {
		let resolvedSize = size ?? theme.dimensions.sm
		Circle()
			.fill(status.color(in: theme.colors))
			.frame(width: resolvedSize, height: resolvedSize)
			.accessibilityIdentifier(accessibilityIdentifier ?? "")
			.accessibilityLabel(status.rawValue)
	}
}

/*
// MARK: - Previews

#Preview("DSStatusIndicator") {
	HStack(spacing: DefaultSpacing().lg) {
		ForEach(DSStatus.allCases, id: \.self) { status in
			VStack(spacing: DefaultSpacing().sm) {
				DSStatusIndicator(status: status)
				DSStatusIndicator(status: status, size: 8)
				DSStatusIndicator(status: status, size: 16)
				Text(status.rawValue.capitalized)
					.font(DefaultTypography().caption)
					.foregroundStyle(DefaultColorPalette().textPrimary)
			}
		}
	}
	.padding()
}
*/
