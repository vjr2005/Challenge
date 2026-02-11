@testable import ChallengeHome

final class AboutViewModelStub: AboutViewModelContract {
	let info: AboutInfo = GetAboutInfoUseCase().execute()

	func didAppear() {
		// No-op: tracking not tested in snapshots
	}

	func didTapClose() {
		// No-op: navigation not tested in snapshots
	}
}
