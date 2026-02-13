import Foundation
import Testing

@testable import ChallengeCore

struct FileAttributesTests {
	// MARK: - Init from Optional Values

	@Test("Creates attributes from complete values")
	func createsAttributesFromCompleteValues() throws {
		// Given
		let modified = Date(timeIntervalSince1970: 1_000)
		let created = Date(timeIntervalSince1970: 500)

		// When
		let result = try FileAttributes(fileSize: 1_024, modificationDate: modified, creationDate: created)

		// Then
		let expected = FileAttributes(size: 1_024, modified: modified, created: created)
		#expect(result == expected)
	}

	@Test("Throws when file size is missing")
	func throwsWhenFileSizeIsMissing() {
		#expect(throws: CocoaError.self) {
			_ = try FileAttributes(fileSize: nil, modificationDate: Date(), creationDate: Date())
		}
	}

	@Test("Throws when modification date is missing")
	func throwsWhenModificationDateIsMissing() {
		#expect(throws: CocoaError.self) {
			_ = try FileAttributes(fileSize: 100, modificationDate: nil, creationDate: Date())
		}
	}

	@Test("Throws when creation date is missing")
	func throwsWhenCreationDateIsMissing() {
		#expect(throws: CocoaError.self) {
			_ = try FileAttributes(fileSize: 100, modificationDate: Date(), creationDate: nil)
		}
	}
}
