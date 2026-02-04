import SwiftUI

private struct DSThemeKey: EnvironmentKey {
	static let defaultValue: DSTheme = .default
}

public extension EnvironmentValues {
	/// The current design system theme
	var dsTheme: DSTheme {
		get { self[DSThemeKey.self] }
		set { self[DSThemeKey.self] = newValue }
	}
}

public extension View {
	/// Sets the design system theme for this view and its children.
	/// - Parameter theme: The theme to apply
	/// - Returns: A view with the theme applied via the environment
	func dsTheme(_ theme: DSTheme) -> some View {
		environment(\.dsTheme, theme)
	}
}
