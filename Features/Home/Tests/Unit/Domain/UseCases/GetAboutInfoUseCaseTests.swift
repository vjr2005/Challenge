import Testing

@testable import ChallengeHome

struct GetAboutInfoUseCaseTests {
	private let sut = GetAboutInfoUseCase()

	// MARK: - Sections

	@Test("Returns three sections: features, dependencies, credits")
	func sectionsStructure() {
		// When
		let result = sut.execute()

		// Then
		#expect(result.sections.count == 3)
		#expect(result.sections.map(\.id) == ["features", "dependencies", "credits"])
	}

	// MARK: - Features

	@Test("Features section contains seven items with correct identifiers and icons")
	func featuresSection() {
		// When
		let section = sut.execute().sections[0]

		// Then
		#expect(section.items.count == 7)
		#expect(section.items.map(\.id) == [
			"about.feature.browse",
			"about.feature.search",
			"about.feature.filters",
			"about.feature.detail",
			"about.feature.episodes",
			"about.feature.navigation",
			"about.feature.localization",
		])
		#expect(section.items.map(\.icon) == [
			"person.2",
			"magnifyingglass",
			"line.3.horizontal.decrease.circle",
			"person.text.rectangle",
			"tv",
			"arrow.triangle.2.circlepath",
			"globe",
		])
	}

	// MARK: - Dependencies

	@Test("Dependencies section contains three items with correct identifiers and icons")
	func dependenciesSection() {
		// When
		let section = sut.execute().sections[1]

		// Then
		#expect(section.items.count == 3)
		#expect(section.items.map(\.id) == [
			"about.dep.lottie",
			"about.dep.snapshot",
			"about.dep.mockServer",
		])
		#expect(section.items.map(\.icon) == [
			"play.rectangle",
			"camera.viewfinder",
			"server.rack",
		])
	}

	// MARK: - Credits

	@Test("Credits section contains three items with correct identifiers and icons")
	func creditsSection() {
		// When
		let section = sut.execute().sections[2]

		// Then
		#expect(section.items.count == 3)
		#expect(section.items.map(\.id) == [
			"about.api",
			"about.developer",
			"about.builtWith",
		])
		#expect(section.items.map(\.icon) == [
			"network",
			"person",
			"wrench.and.screwdriver",
		])
	}

	// MARK: - Content

	@Test("All items have non-empty title and description")
	func allItemsHaveContent() {
		// When
		let result = sut.execute()

		// Then
		for section in result.sections {
			for item in section.items {
				#expect(!item.title.isEmpty, "Item \(item.id) has empty title")
				#expect(!item.description.isEmpty, "Item \(item.id) has empty description")
			}
		}
	}
}
