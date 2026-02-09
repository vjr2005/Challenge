import ChallengeDesignSystem
import SwiftUI

struct EpisodeListView<ViewModel: EpisodeListViewModelContract>: View {
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
                viewModel.didAppear()
            }
    }
}

/*
#if DEBUG
#Preview {
    EpisodeListView(viewModel: EpisodeListViewModelStub())
}
#endif
*/
