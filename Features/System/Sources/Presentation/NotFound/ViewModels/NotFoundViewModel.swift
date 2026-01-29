final class NotFoundViewModel: NotFoundViewModelContract {
    private let navigator: NotFoundNavigatorContract

    init(navigator: NotFoundNavigatorContract) {
        self.navigator = navigator
    }

    func didTapGoBack() {
        navigator.goBack()
    }
}
