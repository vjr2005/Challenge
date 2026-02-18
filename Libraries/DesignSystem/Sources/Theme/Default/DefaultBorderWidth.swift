import Foundation

/// Default border width implementation matching the standard design system scale.
struct DefaultBorderWidth: DSBorderWidthContract {
	var hairline: CGFloat { 0.5 }
	var thin: CGFloat { 1 }
	var medium: CGFloat { 2 }
	var thick: CGFloat { 4 }
}
