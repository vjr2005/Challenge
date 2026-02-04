import SwiftUI

/// Contract for design system typography.
///
/// Conforming types provide font values for each text style.
/// Each property maps to a semantic text style (large title, title, headline, body, etc.).
public protocol DSTypography: Sendable {
	/// Large title font - prominent page headers
	var largeTitle: Font { get }

	/// Title font - section titles
	var title: Font { get }

	/// Title 2 font - secondary section titles
	var title2: Font { get }

	/// Title 3 font - tertiary section titles
	var title3: Font { get }

	/// Headline font - emphasized text
	var headline: Font { get }

	/// Body font - standard content text
	var body: Font { get }

	/// Subheadline font - supporting text below headlines
	var subheadline: Font { get }

	/// Footnote font - auxiliary information
	var footnote: Font { get }

	/// Caption font - labels and annotations
	var caption: Font { get }

	/// Caption 2 font - smallest text style
	var caption2: Font { get }
}
