import SwiftUI

struct HomeView: View {
	/// Not @State: ViewModel has no observable state, just actions.
	let viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Home")
                .font(.largeTitle)

            Button("Go to Characters") {
                viewModel.didTapOnCharacterButton()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
