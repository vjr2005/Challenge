import SwiftUI

/// Status types for the status indicator.
public enum DSStatus: String, CaseIterable, Sendable {
	/// Alive/active/success status
	case alive

	/// Dead/inactive/error status
	case dead

	/// Unknown/neutral status
	case unknown

	/// The color associated with this status
	public var color: Color {
		switch self {
		case .alive:
			ColorToken.statusSuccess
		case .dead:
			ColorToken.statusError
		case .unknown:
			ColorToken.statusNeutral
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
	private let size: CGFloat
	private let accessibilityIdentifier: String?

	/// Creates a DSStatusIndicator.
	/// - Parameters:
	///   - status: The status to display
	///   - size: The size of the indicator (default: IconSizeToken.sm)
	///   - accessibilityIdentifier: Optional accessibility identifier for UI testing
	public init(
		status: DSStatus,
		size: CGFloat = IconSizeToken.sm,
		accessibilityIdentifier: String? = nil
	) {
		self.status = status
		self.size = size
		self.accessibilityIdentifier = accessibilityIdentifier
	}

	public var body: some View {
		Circle()
			.fill(status.color)
			.frame(width: size, height: size)
			.accessibilityIdentifier(accessibilityIdentifier ?? "")
			.accessibilityLabel(status.rawValue)
	}
}

#Preview("DSStatusIndicator") {
	HStack(spacing: SpacingToken.lg) {
		ForEach(DSStatus.allCases, id: \.self) { status in
			VStack(spacing: SpacingToken.sm) {
				DSStatusIndicator(status: status)
				DSStatusIndicator(status: status, size: IconSizeToken.xs)
				DSStatusIndicator(status: status, size: IconSizeToken.md)
				Text(status.rawValue.capitalized)
					.font(TextStyle.caption.font)
					.foregroundStyle(ColorToken.textPrimary)
			}
		}
	}
	.padding()
}
