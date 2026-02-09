import SwiftUI

/// A selectable chip component that follows the design system.
public struct DSChip: View {
    private let title: String
    private let isSelected: Bool
    private let accessibilityIdentifier: String?
    private let action: () -> Void

    @Environment(\.dsTheme) private var theme

    /// Creates a DSChip.
    /// - Parameters:
    ///   - title: The chip label text
    ///   - isSelected: Whether the chip is currently selected
    ///   - accessibilityIdentifier: Optional accessibility identifier for UI testing
    ///   - action: The action to perform when tapped
    public init(
        _ title: String,
        isSelected: Bool,
        accessibilityIdentifier: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(theme.typography.subheadline)
                .foregroundStyle(foregroundColor)
                .padding(.horizontal, theme.spacing.md)
                .padding(.vertical, theme.spacing.sm)
                .background(backgroundColor)
                .clipShape(Capsule())
                .overlay {
                    if !isSelected {
                        Capsule()
                            .stroke(theme.colors.separator, lineWidth: theme.borderWidth.thin)
                    }
                }
        }
        .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }

    private var foregroundColor: Color {
        isSelected ? theme.colors.textInverted : theme.colors.textPrimary
    }

    private var backgroundColor: Color {
        isSelected ? theme.colors.accent : Color.clear
    }
}

/*
// MARK: - Previews

#Preview("DSChip") {
    HStack(spacing: DefaultSpacing().sm) {
        DSChip("Alive", isSelected: true) {}
        DSChip("Dead", isSelected: false) {}
        DSChip("Unknown", isSelected: false) {}
    }
    .padding()
}
*/
