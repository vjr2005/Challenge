nonisolated struct AboutInfo: Equatable {
	let sections: [AboutSection]
}

nonisolated struct AboutSection: Equatable, Identifiable {
	let id: String
	let items: [AboutItem]
}

nonisolated struct AboutItem: Equatable, Identifiable {
	let id: String
	let icon: String
	let title: String
	let description: String
}
