import SwiftUI

/// The default typography with rounded, serif, and monospaced font designs.
struct DefaultTypography: DSTypographyContract {
	var largeTitle: Font {
		.system(.largeTitle, design: .rounded, weight: .bold)
	}

	var title: Font {
		.system(.title, design: .rounded, weight: .bold)
	}

	var title2: Font {
		.system(.title2, design: .rounded, weight: .semibold)
	}

	var title3: Font {
		.system(.title3, design: .rounded, weight: .semibold)
	}

	var headline: Font {
		.system(.headline, design: .rounded, weight: .semibold)
	}

	var body: Font {
		.system(.body, design: .rounded)
	}

	var subheadline: Font {
		.system(.subheadline, design: .serif)
	}

	var footnote: Font {
		.system(.footnote, design: .rounded)
	}

	var caption: Font {
		.system(.caption, design: .rounded)
	}

	var caption2: Font {
		.system(.caption2, design: .monospaced)
	}
}
