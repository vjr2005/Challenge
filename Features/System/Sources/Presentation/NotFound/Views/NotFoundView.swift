import ChallengeDesignSystem
import ChallengeResources
import SwiftUI

struct NotFoundView<ViewModel: NotFoundViewModelContract>: View {
    let viewModel: ViewModel

    var body: some View {
        DSEmptyState(
            icon: "questionmark.circle",
            title: LocalizedStrings.title,
            message: LocalizedStrings.message,
            actionTitle: LocalizedStrings.goBack,
            action: {
                viewModel.didTapGoBack()
            },
            accessibilityIdentifier: AccessibilityIdentifier.container
        )
    }
}

// MARK: - LocalizedStrings

private enum LocalizedStrings {
    static var title: String { "system.notFound.title".localized() }
    static var message: String { "system.notFound.message".localized() }
    static var goBack: String { "system.notFound.goBack".localized() }
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let container = "system.notFound.container"
}

// MARK: - Previews

#if DEBUG
#Preview {
    NotFoundView(viewModel: NotFoundViewModelPreviewStub())
}

private final class NotFoundViewModelPreviewStub: NotFoundViewModelContract {
    func didTapGoBack() {}
}
#endif
