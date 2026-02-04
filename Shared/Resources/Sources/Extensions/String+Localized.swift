import Foundation

public extension String {
    /// Returns the localized version of the string from the module's `Localizable` table.
    ///
    /// Uses `Bundle.module` to resolve the localization, falling back to the original key
    /// if no matching entry is found.
    ///
    /// - Returns: The localized string, or the key itself if no localization is found.
    func localized() -> String {
        Bundle.module.localizedString(forKey: self, value: nil, table: nil)
    }

    /// Returns the localized version of the string, interpolating the given format arguments.
    ///
    /// Internally resolves the localized format string via ``localized()`` and applies
    /// `String(format:arguments:)` with the provided values.
    ///
    /// - Parameter arguments: The values to interpolate into the localized format string.
    /// - Returns: The localized and formatted string.
    func localized(_ arguments: CVarArg...) -> String {
        String(format: localized(), arguments: arguments)
    }
}
