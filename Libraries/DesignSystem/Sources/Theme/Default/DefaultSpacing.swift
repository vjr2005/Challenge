import Foundation

/// Default spacing implementation matching the standard design system scale.
struct DefaultSpacing: DSSpacingContract {
	var xxs: CGFloat { 2 }
	var xs: CGFloat { 4 }
	var sm: CGFloat { 8 }
	var md: CGFloat { 12 }
	var lg: CGFloat { 16 }
	var xl: CGFloat { 20 }
	var xxl: CGFloat { 24 }
	var xxxl: CGFloat { 32 }
}
