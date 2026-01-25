import Foundation

public extension String {
	/// Returns the localized version of the string using the Common module's bundle.
	/// - Returns: The localized string, or the original string if no localization is found.
	func localized() -> String {
		String(localized: LocalizationValue(self), bundle: .module)
	}

	/// Returns the localized version of the string with format arguments.
	/// - Parameter arguments: The arguments to interpolate into the localized string.
	/// - Returns: The localized and formatted string.
	func localized(_ arguments: CVarArg...) -> String {
		let localizedFormat = String(localized: LocalizationValue(self), bundle: .module)
		return String(format: localizedFormat, arguments: arguments)
	}
}
