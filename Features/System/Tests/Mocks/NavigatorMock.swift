import ChallengeCore

final class NavigatorMock: NavigatorContract, @unchecked Sendable {
    private(set) var navigatedDestinations: [any Navigation] = []
    private(set) var goBackCallCount = 0

    func navigate(to destination: any Navigation) {
        navigatedDestinations.append(destination)
    }

    func goBack() {
        goBackCallCount += 1
    }
}
