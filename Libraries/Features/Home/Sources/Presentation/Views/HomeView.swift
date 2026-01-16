import SwiftUI

struct HomeView: View {
    let viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Home")
                .font(.largeTitle)

            Button("Go to Character") {
                viewModel.didTapOnCharacterButton()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
