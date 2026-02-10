import ChallengeDesignSystem
import SwiftUI

struct CharacterEpisodesView<ViewModel: CharacterEpisodesViewModelContract>: View {
	// MARK: - Properties

	@State private var viewModel: ViewModel

	// MARK: - Init

	init(viewModel: ViewModel) {
		_viewModel = State(initialValue: viewModel)
	}

	// MARK: - Body

	var body: some View {
		Text("Episode")
			.onFirstAppear {
				await viewModel.didAppear()
			}
	}
}

/*
#if DEBUG
#Preview {
	CharacterEpisodesView(viewModel: CharacterEpisodesViewModelStub())
}
#endif
*/
