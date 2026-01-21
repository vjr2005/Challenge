import SwiftUI

/// A text component that uses design system text styles.
public struct DSText: View {
	private let text: String
	private let style: TextStyle
	private let color: Color?

	/// Creates a DSText with the specified style.
	/// - Parameters:
	///   - text: The text to display
	///   - style: The text style to apply
	///   - color: Optional custom color (defaults to style's default color)
	public init(_ text: String, style: TextStyle, color: Color? = nil) {
		self.text = text
		self.style = style
		self.color = color
	}

	public var body: some View {
		Text(text)
			.font(style.font)
			.foregroundStyle(color ?? style.defaultColor)
	}
}

#Preview("DSText Styles") {
	VStack(alignment: .leading, spacing: SpacingToken.md) {
		DSText("Large Title", style: .largeTitle)
		DSText("Title", style: .title)
		DSText("Title 2", style: .title2)
		DSText("Title 3", style: .title3)
		DSText("Headline", style: .headline)
		DSText("Body", style: .body)
		DSText("Subheadline", style: .subheadline)
		DSText("Footnote", style: .footnote)
		DSText("Caption", style: .caption)
		DSText("Caption 2", style: .caption2)
	}
	.padding()
}

#Preview("DSText Custom Colors") {
	VStack(alignment: .leading, spacing: SpacingToken.md) {
		DSText("Success", style: .headline, color: ColorToken.statusSuccess)
		DSText("Error", style: .headline, color: ColorToken.statusError)
		DSText("Warning", style: .headline, color: ColorToken.statusWarning)
		DSText("Accent", style: .headline, color: ColorToken.accent)
	}
	.padding()
}
