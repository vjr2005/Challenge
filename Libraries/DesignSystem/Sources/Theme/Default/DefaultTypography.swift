import SwiftUI

/// The default typography with rounded, serif, and monospaced font designs.
public struct DefaultTypography: DSTypographyContract {
	/// Creates a new default typography
	public init() {}

	public var largeTitle: Font {
		.system(.largeTitle, design: .rounded, weight: .bold)
	}

	public var title: Font {
		.system(.title, design: .rounded, weight: .bold)
	}

	public var title2: Font {
		.system(.title2, design: .rounded, weight: .semibold)
	}

	public var title3: Font {
		.system(.title3, design: .rounded, weight: .semibold)
	}

	public var headline: Font {
		.system(.headline, design: .rounded, weight: .semibold)
	}

	public var body: Font {
		.system(.body, design: .rounded)
	}

	public var subheadline: Font {
		.system(.subheadline, design: .serif)
	}

	public var footnote: Font {
		.system(.footnote, design: .rounded)
	}

	public var caption: Font {
		.system(.caption, design: .rounded)
	}

	public var caption2: Font {
		.system(.caption2, design: .monospaced)
	}
}
