import SwiftUI

public extension View {
	/// Applies an accessibility identifier with automatic propagation to Design System components.
	///
	/// This modifier applies the standard SwiftUI accessibility identifier and also propagates
	/// the identifier through the environment to child Design System components, which will
	/// automatically apply it with their default suffixes.
	///
	/// Example:
	/// ```swift
	/// CharacterRowView(character: character)
	///     .dsAccessibilityIdentifier("characterList.row.1")
	/// // Results in:
	/// // - Container: "characterList.row.1"
	/// // - DSAsyncImage: "characterList.row.1.image"
	/// // - DSText (name): "characterList.row.1.name"
	/// // - DSStatusIndicator: "characterList.row.1.status"
	/// ```
	///
	/// - Parameter identifier: The accessibility identifier string.
	/// - Returns: A view with the accessibility identifier applied and propagated to DS descendants.
	func dsAccessibilityIdentifier(_ identifier: String) -> some View {
		self
			.accessibilityElement(children: .contain)
			.accessibilityIdentifier(identifier)
			.environment(\.dsAccessibilityIdentifier, DSAccessibilityIdentifier(identifier))
	}
}
