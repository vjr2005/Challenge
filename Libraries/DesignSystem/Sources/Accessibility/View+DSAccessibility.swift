import SwiftUI

extension View {
	/// Applies an accessibility identifier derived from the parent identifier and a suffix.
	///
	/// This internal helper is used by Design System components to automatically apply
	/// accessibility identifiers based on the propagated environment value.
	///
	/// - Parameters:
	///   - parentIdentifier: The accessibility identifier propagated from the parent view.
	///   - suffix: The suffix to append to the parent identifier.
	/// - Returns: A view with the accessibility identifier applied, or the original view if no parent identifier exists.
	@ViewBuilder
	func dsAccessibility(
		parentIdentifier: DSAccessibilityIdentifier?,
		suffix: String?,
		traits: AccessibilityTraits = []
	) -> some View {
		if let parentIdentifier, let suffix {
			self
				.accessibilityIdentifier(parentIdentifier.appending(suffix).rawValue)
				.accessibilityAddTraits(traits)
		} else if let parentIdentifier {
			self
				.accessibilityIdentifier(parentIdentifier.rawValue)
				.accessibilityAddTraits(traits)
		} else if !traits.isEmpty {
			self.accessibilityAddTraits(traits)
		} else {
			self
		}
	}
}
