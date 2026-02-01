import SwiftUI

/// Environment key for propagating accessibility identifiers through the view hierarchy.
private struct DSAccessibilityIdentifierKey: EnvironmentKey {
	static let defaultValue: DSAccessibilityIdentifier? = nil
}

public extension EnvironmentValues {
	/// The accessibility identifier propagated from parent views.
	///
	/// Design System components read this value to automatically apply
	/// accessibility identifiers with their default suffixes.
	var dsAccessibilityIdentifier: DSAccessibilityIdentifier? {
		get { self[DSAccessibilityIdentifierKey.self] }
		set { self[DSAccessibilityIdentifierKey.self] = newValue }
	}
}
