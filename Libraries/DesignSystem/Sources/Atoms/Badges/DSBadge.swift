import SwiftUI

/// A generic wrapper view that overlays a count badge on any content.
public struct DSBadge<Content: View>: View {
	private let badgeCount: Int
	private let content: Content

	@Environment(\.dsTheme) private var theme

	/// Creates a DSBadge.
	/// - Parameters:
	///   - count: The count to display. Badge is hidden when count is 0 or less.
	///   - content: The content to overlay the badge on.
	public init(count: Int, @ViewBuilder content: () -> Content) {
		self.badgeCount = count
		self.content = content()
	}

	public var body: some View {
		content
			.overlay(alignment: .topTrailing) {
				if badgeCount > 0 {
					Text("\(badgeCount)")
                        .font(theme.typography.caption2.bold())
						.foregroundStyle(theme.colors.textInverted)
						.padding(.horizontal, theme.spacing.xxs)
						.frame(minWidth: theme.dimensions.sm, minHeight: theme.dimensions.sm)
						.background(theme.colors.accent)
						.clipShape(Capsule())
						.offset(x: theme.spacing.xs, y: -theme.spacing.xs)
				}
			}
	}
}

/*
// MARK: - Previews

#Preview {
    HStack(spacing: DefaultSpacing().xl) {
        DSBadge(count: 0) {
            Image(systemName: "bell")
        }
        DSBadge(count: 1) {
            Image(systemName: "bell")
        }
        DSBadge(count: 9) {
            Image(systemName: "bell")
        }
        DSBadge(count: 42) {
            Image(systemName: "bell")
        }
    }
    .padding()
}
*/
