import SwiftUI

/// A styled text field component that follows the design system.
public struct DSTextField: View {
    private let placeholder: String
    @Binding private var text: String
    private let accessibilityIdentifier: String?

    @Environment(\.dsTheme) private var theme

    /// Creates a DSTextField.
    /// - Parameters:
    ///   - placeholder: Placeholder text shown when the field is empty
    ///   - text: Binding to the text value
    ///   - accessibilityIdentifier: Optional accessibility identifier for UI testing
    public init(
        placeholder: String,
        text: Binding<String>,
        accessibilityIdentifier: String? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.accessibilityIdentifier = accessibilityIdentifier
    }

    public var body: some View {
        TextField(placeholder, text: $text)
            .font(theme.typography.body)
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
            .background(theme.colors.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.md))
            .overlay {
                RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                    .stroke(theme.colors.separator, lineWidth: theme.borderWidth.thin)
            }
            .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }
}

/*
// MARK: - Previews

#Preview("DSTextField") {
    VStack(spacing: DefaultSpacing().lg) {
        DSTextField(placeholder: "Search...", text: .constant(""))
        DSTextField(placeholder: "Search...", text: .constant("Rick Sanchez"))
    }
    .padding()
}
*/
