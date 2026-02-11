struct AboutInfo: Equatable {
	let sections: [AboutSection]
}

struct AboutSection: Equatable, Identifiable {
	let id: String
	let items: [AboutItem]
}

struct AboutItem: Equatable, Identifiable {
	let id: String
	let icon: String
	let title: String
	let description: String
}
