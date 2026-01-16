import ChallengeCore
import SwiftUI

public enum HomeFeature {
    private static let container = HomeContainer()

    @MainActor
    public static func makeHomeView(router: RouterContract) -> some View {
        let viewModel = container.makeHomeViewModel(router: router)
        return HomeView(viewModel: viewModel)
    }
}
