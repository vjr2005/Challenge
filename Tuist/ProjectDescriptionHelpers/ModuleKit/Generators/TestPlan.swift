import Foundation

/// Type-safe model for the `.xctestplan` JSON schema.
///
/// Used by ``TestPlanGenerator`` to build the test plan structure and
/// serialize it with `JSONEncoder` instead of untyped dictionaries.

// MARK: - Root

struct TestPlan: Encodable {
	let configurations: [TestPlanConfiguration]
	let defaultOptions: TestPlanDefaultOptions
	let testTargets: [TestPlanTestTargetEntry]
	let version: Int
}

// MARK: - Configuration

struct TestPlanConfiguration: Encodable {
	let id: String
	let name: String
	let options: TestPlanEmptyObject

	init(name: String) {
		self.id = UUID().uuidString
		self.name = name
		self.options = TestPlanEmptyObject()
	}
}

/// Encodes to an empty JSON object `{}`.
struct TestPlanEmptyObject: Encodable {}

// MARK: - Default Options

struct TestPlanDefaultOptions: Encodable {
	let codeCoverage: TestPlanCodeCoverage
}

struct TestPlanCodeCoverage: Encodable {
	let targets: [TestPlanCoverageTarget]
}

struct TestPlanCoverageTarget: Encodable {
	let containerPath: String
	let identifier: String
	let name: String
}

// MARK: - Test Targets

struct TestPlanTestTargetEntry: Encodable {
	let target: TestPlanTestTarget
}

struct TestPlanTestTarget: Encodable {
	let containerPath: String
	let identifier: String
	let name: String
}
