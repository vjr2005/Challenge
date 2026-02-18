import Foundation

/// Default opacity implementation matching the standard design system scale.
struct DefaultOpacity: DSOpacityContract {
	var subtle: Double { 0.1 }
	var light: Double { 0.15 }
	var medium: Double { 0.4 }
	var heavy: Double { 0.6 }
	var almostOpaque: Double { 0.8 }
}
