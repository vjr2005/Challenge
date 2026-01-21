import SwiftUI

/// A status badge that combines a status indicator with a label.
public struct DSStatusBadge: View {
	private let status: DSStatus
	private let label: String
	private let showIndicator: Bool

	/// Creates a DSStatusBadge.
	/// - Parameters:
	///   - status: The status to display
	///   - label: The label text (defaults to status name)
	///   - showIndicator: Whether to show the status indicator dot (default: true)
	public init(
		status: DSStatus,
		label: String? = nil,
		showIndicator: Bool = true
	) {
		self.status = status
		self.label = label ?? status.rawValue.capitalized
		self.showIndicator = showIndicator
	}

	public var body: some View {
		HStack(spacing: SpacingToken.xs) {
			if showIndicator {
				DSStatusIndicator(status: status, size: IconSizeToken.xs)
			}

			Text(label)
				.font(TextStyle.caption.font)
				.foregroundStyle(status.color)
		}
		.padding(.horizontal, SpacingToken.sm)
		.padding(.vertical, SpacingToken.xs)
		.background(status.color.opacity(OpacityToken.light))
		.clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.sm))
	}
}

#Preview("DSStatusBadge") {
	VStack(spacing: SpacingToken.md) {
		DSStatusBadge(status: .alive)
		DSStatusBadge(status: .dead)
		DSStatusBadge(status: .unknown)
		DSStatusBadge(status: .alive, label: "Active")
		DSStatusBadge(status: .alive, showIndicator: false)
	}
	.padding()
}
