import Foundation
import SwiftData

@ModelActor
actor CharacterEntityDataSource: CharacterLocalDataSourceContract {
	private let entityMapper = CharacterEntityMapper()
	private let entityDTOMapper = CharacterEntityDTOMapper()
	private let pageEntityDTOMapper = CharactersPageEntityDTOMapper()

	// MARK: - Character Detail

	func getCharacter(identifier: Int) -> CharacterDTO? {
		let descriptor = FetchDescriptor<CharacterEntity>(
			predicate: #Predicate { $0.identifier == identifier }
		)
		guard let entity = try? modelContext.fetch(descriptor).first else { return nil }
		return entityDTOMapper.map(entity)
	}

	func saveCharacter(_ character: CharacterDTO) {
		insertCharacter(character)
		try? modelContext.save()
	}

	// MARK: - Paginated Results

	func getPage(_ page: Int) -> CharactersResponseDTO? {
		let descriptor = FetchDescriptor<CharactersPageEntity>(
			predicate: #Predicate { $0.page == page }
		)
		guard let pageEntity = try? modelContext.fetch(descriptor).first else { return nil }
		return pageEntityDTOMapper.map(pageEntity)
	}

	func savePage(_ response: CharactersResponseDTO, page: Int) {
		let pageDescriptor = FetchDescriptor<CharactersPageEntity>(
			predicate: #Predicate { $0.page == page }
		)
		if let existingPage = try? modelContext.fetch(pageDescriptor).first {
			modelContext.delete(existingPage)
		}

		let characterEntities = response.results.map { insertCharacter($0) }

		let pageEntity = CharactersPageEntity(
			page: page,
			count: response.info.count,
			pages: response.info.pages,
			next: response.info.next,
			prev: response.info.prev,
			characters: characterEntities
		)
		modelContext.insert(pageEntity)
		try? modelContext.save()
	}

	// MARK: - Search

	func searchCharacters(page: Int, filter: CharacterFilterDTO) -> CharactersResponseDTO? {
		guard page >= 1 else { return nil }

		let predicate = buildSearchPredicate(filter: filter)
		let descriptor = FetchDescriptor<CharacterEntity>(
			predicate: predicate,
			sortBy: [SortDescriptor(\.identifier)]
		)

		guard let allEntities = try? modelContext.fetch(descriptor), !allEntities.isEmpty else {
			return nil
		}

		let totalCount = allEntities.count
		let totalPages = max(1, Int(ceil(Double(totalCount) / Double(Self.pageSize))))
		guard page <= totalPages else { return nil }

		let startIndex = (page - 1) * Self.pageSize
		let endIndex = min(startIndex + Self.pageSize, totalCount)
		let pageEntities = allEntities[startIndex..<endIndex]

		return CharactersResponseDTO(
			info: PaginationInfoDTO(
				count: totalCount,
				pages: totalPages,
				next: page < totalPages ? String(page + 1) : nil,
				prev: page > 1 ? String(page - 1) : nil
			),
			results: pageEntities.map { entityDTOMapper.map($0) }
		)
	}
}

// MARK: - Private

private extension CharacterEntityDataSource {
	static let pageSize = 20

	@discardableResult
	func insertCharacter(_ dto: CharacterDTO) -> CharacterEntity {
		let entity = entityMapper.map(dto)
		modelContext.insert(entity)
		return entity
	}

	func buildSearchPredicate(filter: CharacterFilterDTO) -> Predicate<CharacterEntity> {
		let hasName = filter.name != nil
		let nameValue = filter.name ?? ""
		let hasStatus = filter.status != nil
		let statusValue = (filter.status ?? "").capitalized
		let hasSpecies = filter.species != nil
		let speciesValue = filter.species ?? ""
		let hasType = filter.type != nil
		let typeValue = filter.type ?? ""
		let hasGender = filter.gender != nil
		let genderValue = (filter.gender ?? "").capitalized

		return #Predicate<CharacterEntity> { entity in
			(!hasName || entity.name.localizedStandardContains(nameValue)) &&
			(!hasStatus || entity.status == statusValue) &&
			(!hasSpecies || entity.species.localizedStandardContains(speciesValue)) &&
			(!hasType || entity.type.localizedStandardContains(typeValue)) &&
			(!hasGender || entity.gender == genderValue)
		}
	}
}
