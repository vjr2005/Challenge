import SwiftUI

public extension View {
	/// Performs an action only the first time the view appears.
	///
	/// This replicates the behavior of UIKit's `viewDidLoad`:
	/// the closure executes once when the view first appears
	/// and is not called again on subsequent appearances.
	///
	/// - Parameter action: The async action to perform on first appear.
	/// - Returns: A view that triggers the action once.
	func onFirstAppear(perform action: @escaping () async -> Void) -> some View {
		modifier(OnFirstAppearModifier(action: action))
	}
}

private struct OnFirstAppearModifier: ViewModifier {
	let action: () async -> Void

	@State private var hasAppeared = false

	func body(content: Content) -> some View {
		content
			.task {
                guard !hasAppeared else {
                    return
                }
				hasAppeared = true
				await action()
			}
	}
}
