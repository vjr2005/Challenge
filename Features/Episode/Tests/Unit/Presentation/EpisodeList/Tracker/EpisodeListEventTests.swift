import Testing

@testable import ChallengeEpisode

struct EpisodeListEventTests {
    // MARK: - Screen Viewed

    @Test("Screen viewed has correct name")
    func screenViewedHasCorrectName() {
        #expect(EpisodeListEvent.screenViewed.name == "episode_list_viewed")
    }

    @Test("Screen viewed has empty properties")
    func screenViewedHasEmptyProperties() {
        #expect(EpisodeListEvent.screenViewed.properties == [:])
    }
}
