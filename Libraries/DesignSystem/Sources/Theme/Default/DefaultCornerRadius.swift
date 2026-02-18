import Foundation

/// Default corner radius implementation matching the standard design system scale.
struct DefaultCornerRadius: DSCornerRadiusContract {
	var zero: CGFloat { 0 }
	var xs: CGFloat { 4 }
	var sm: CGFloat { 8 }
	var md: CGFloat { 12 }
	var lg: CGFloat { 16 }
	var xl: CGFloat { 20 }
	var full: CGFloat { 9999 }
}
