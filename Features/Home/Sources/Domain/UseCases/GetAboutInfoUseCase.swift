import ChallengeResources

struct GetAboutInfoUseCase: GetAboutInfoUseCaseContract {
	func execute() -> AboutInfo {
		AboutInfo(sections: [
			featuresSection,
			dependenciesSection,
			creditsSection,
		])
	}
}

// MARK: - Sections

private extension GetAboutInfoUseCase {
	var featuresSection: AboutSection {
		AboutSection(id: "features", items: [
			AboutItem(
				id: "about.feature.browse",
				icon: "person.2",
				title: "about.feature.browse".localized(),
				description: "about.feature.browseValue".localized()
			),
			AboutItem(
				id: "about.feature.search",
				icon: "magnifyingglass",
				title: "about.feature.search".localized(),
				description: "about.feature.searchValue".localized()
			),
			AboutItem(
				id: "about.feature.filters",
				icon: "line.3.horizontal.decrease.circle",
				title: "about.feature.filters".localized(),
				description: "about.feature.filtersValue".localized()
			),
			AboutItem(
				id: "about.feature.detail",
				icon: "person.text.rectangle",
				title: "about.feature.detail".localized(),
				description: "about.feature.detailValue".localized()
			),
			AboutItem(
				id: "about.feature.episodes",
				icon: "tv",
				title: "about.feature.episodes".localized(),
				description: "about.feature.episodesValue".localized()
			),
			AboutItem(
				id: "about.feature.navigation",
				icon: "arrow.triangle.2.circlepath",
				title: "about.feature.navigation".localized(),
				description: "about.feature.navigationValue".localized()
			),
			AboutItem(
				id: "about.feature.localization",
				icon: "globe",
				title: "about.feature.localization".localized(),
				description: "about.feature.localizationValue".localized()
			),
		])
	}

	var dependenciesSection: AboutSection {
		AboutSection(id: "dependencies", items: [
			AboutItem(
				id: "about.dep.lottie",
				icon: "play.rectangle",
				title: "about.dep.lottie".localized(),
				description: "about.dep.lottieValue".localized()
			),
			AboutItem(
				id: "about.dep.snapshot",
				icon: "camera.viewfinder",
				title: "about.dep.snapshot".localized(),
				description: "about.dep.snapshotValue".localized()
			),
			AboutItem(
				id: "about.dep.mockServer",
				icon: "server.rack",
				title: "about.dep.mockServer".localized(),
				description: "about.dep.mockServerValue".localized()
			),
		])
	}

	var creditsSection: AboutSection {
		AboutSection(id: "credits", items: [
			AboutItem(
				id: "about.api",
				icon: "network",
				title: "about.api".localized(),
				description: "about.apiValue".localized()
			),
			AboutItem(
				id: "about.developer",
				icon: "person",
				title: "about.developer".localized(),
				description: "about.developerValue".localized()
			),
			AboutItem(
				id: "about.builtWith",
				icon: "wrench.and.screwdriver",
				title: "about.builtWith".localized(),
				description: "about.builtWithValue".localized()
			),
		])
	}
}
