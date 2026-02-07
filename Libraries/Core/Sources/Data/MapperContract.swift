import Foundation

/// Contract for mapping between data transfer objects and domain models.
public protocol MapperContract<Input, Output>: Sendable {
	associatedtype Input
	associatedtype Output
	func map(_ input: Input) -> Output
}
