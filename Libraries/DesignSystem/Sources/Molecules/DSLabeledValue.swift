import SwiftUI

/// Orientation options for labeled values.
public enum DSLabeledValueOrientation {
	/// Label above value (vertical stack)
	case vertical

	/// Label and value side by side (horizontal stack)
	case horizontal
}

/// A labeled value component that displays a label-value pair.
public struct DSLabeledValue: View {
	private let label: String
	private let value: String
	private let orientation: DSLabeledValueOrientation
	private let labelStyle: TextStyle
	private let valueStyle: TextStyle

	/// Creates a DSLabeledValue.
	/// - Parameters:
	///   - label: The label text
	///   - value: The value text
	///   - orientation: The layout orientation (default: .vertical)
	///   - labelStyle: The label text style (default: .caption)
	///   - valueStyle: The value text style (default: .body)
	public init(
		label: String,
		value: String,
		orientation: DSLabeledValueOrientation = .vertical,
		labelStyle: TextStyle = .caption,
		valueStyle: TextStyle = .body
	) {
		self.label = label
		self.value = value
		self.orientation = orientation
		self.labelStyle = labelStyle
		self.valueStyle = valueStyle
	}

	public var body: some View {
		switch orientation {
		case .vertical:
			VStack(alignment: .leading, spacing: SpacingToken.xxs) {
				DSText(label, style: labelStyle, color: ColorToken.textSecondary)
				DSText(value, style: valueStyle)
			}
		case .horizontal:
			HStack {
				DSText(label, style: labelStyle, color: ColorToken.textSecondary)
				Spacer()
				DSText(value, style: valueStyle)
			}
		}
	}
}

#if DEBUG
#Preview("DSLabeledValue Vertical") {
	VStack(alignment: .leading, spacing: SpacingToken.lg) {
		DSLabeledValue(label: "Species", value: "Human")
		DSLabeledValue(label: "Gender", value: "Male")
		DSLabeledValue(label: "Origin", value: "Earth (C-137)")
	}
	.padding()
}

#Preview("DSLabeledValue Horizontal") {
	VStack(spacing: SpacingToken.md) {
		DSLabeledValue(label: "Species", value: "Human", orientation: .horizontal)
		DSLabeledValue(label: "Gender", value: "Male", orientation: .horizontal)
		DSLabeledValue(label: "Origin", value: "Earth (C-137)", orientation: .horizontal)
	}
	.padding()
}
#endif
