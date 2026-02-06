import SwiftUI

/// A labeled horizontal group of selectable chips with single-select toggle behavior.
public struct DSChipGroup<ID: Hashable>: View {
    private let title: String
    private let options: [(id: ID, label: String)]
    private let selectedID: ID?
    private let accessibilityIdentifier: String?
    private let onSelect: (ID?) -> Void

    @Environment(\.dsTheme) private var theme

    /// Creates a DSChipGroup.
    /// - Parameters:
    ///   - title: The group label displayed above the chips
    ///   - options: The available chip options as (id, label) pairs
    ///   - selectedID: The currently selected option ID, or nil if none
    ///   - accessibilityIdentifier: Optional accessibility identifier prefix for UI testing
    ///   - onSelect: Callback with the selected ID, or nil when deselected
    public init(
        _ title: String,
        options: [(id: ID, label: String)],
        selectedID: ID?,
        accessibilityIdentifier: String? = nil,
        onSelect: @escaping (ID?) -> Void
    ) {
        self.title = title
        self.options = options
        self.selectedID = selectedID
        self.accessibilityIdentifier = accessibilityIdentifier
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text(title)
                .font(theme.typography.headline)
                .foregroundStyle(theme.colors.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: theme.spacing.sm) {
                    ForEach(options, id: \.id) { option in
                        DSChip(
                            option.label,
                            isSelected: selectedID == option.id,
                            accessibilityIdentifier: chipAccessibilityIdentifier(for: option.label)
                        ) {
                            if selectedID == option.id {
                                onSelect(nil)
                            } else {
                                onSelect(option.id)
                            }
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }

    private func chipAccessibilityIdentifier(for label: String) -> String? {
        guard let prefix = accessibilityIdentifier else {
            return nil
        }
        return "\(prefix).\(label)"
    }
}
