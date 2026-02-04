import Testing

@testable import ChallengeDesignSystem

@Suite("TextStyle")
struct TextStyleTests {
	@Test("All text style cases exist")
	func allCasesExist() {
		let styles: [TextStyle] = [
			.largeTitle, .title, .title2, .title3, .headline,
			.body, .subheadline, .footnote, .caption, .caption2
		]

		#expect(styles.count == 10)
	}
}
