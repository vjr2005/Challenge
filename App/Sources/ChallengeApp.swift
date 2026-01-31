import ChallengeAppKit
import SwiftUI

@main
struct ChallengeApp: App {
	private let appContainer = AppContainer()

	var body: some Scene {
		WindowGroup {
			RootContainerView(appContainer: appContainer)
		}
	}
}
