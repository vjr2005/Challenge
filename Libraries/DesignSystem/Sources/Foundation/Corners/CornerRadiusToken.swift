import Foundation

/// Design tokens for corner radius values.
public enum CornerRadiusToken {
	/// No corner radius (0pt)
	public static let zero: CGFloat = 0

	/// Extra small corner radius (4pt)
	public static let xs: CGFloat = 4

	/// Small corner radius (8pt)
	public static let sm: CGFloat = 8

	/// Medium corner radius (12pt)
	public static let md: CGFloat = 12

	/// Large corner radius (16pt)
	public static let lg: CGFloat = 16

	/// Extra large corner radius (20pt)
	public static let xl: CGFloat = 20

	/// Full/circular corner radius (9999pt)
	public static let full: CGFloat = 9999
}
