import SnapshotTesting
import SwiftUI
import UIKit

/// Snapshot strategy for visual regression tests.
///
/// Each strategy determines how the view is hosted and captured:
/// - ``image``: Use for isolated components that size themselves (e.g. `DSBadge`, `DSTextField`).
/// - ``device``: Use for full-screen views embedded in a navigation hierarchy (e.g. `CharacterListView`, `AboutView`).
/// - ``presentationLayer``: Use for views that rely on Core Animation (e.g. Lottie). Captures `layer.presentation()` instead of the model layer.
/// - ``component(size:)``: Use for components that require a live `UIWindow` to render correctly (e.g. `DSChip`, which wraps content in a `Button`).
public enum SnapshotStrategy {
	/// Intrinsic size (`.sizeThatFits`).
	///
	/// Use for self-sizing components that don't need a real view hierarchy.
	case image

	/// iPhone 13 Pro Max (428×926).
	///
	/// Use for full-screen views wrapped in `NavigationStack`.
	case device

	/// Captures the Core Animation presentation tree (`layer.presentation()`).
	///
	/// Use for views that animate via `CAAnimation` (e.g. Lottie), where the visible state
	/// only exists in the presentation layer. For static views, produces the same result as ``device``.
	case presentationLayer

	/// Explicit dimensions inside a `UIWindow`.
	///
	/// Use for components that need a live view hierarchy to render correctly.
	/// `Button` chrome requires a window to render — this is the primary use case.
	case component(size: CGSize)
}

// MARK: - SwiftUI View

/// Asserts a snapshot of a SwiftUI `View`.
/// - Parameters:
///   - value: The SwiftUI view to snapshot.
///   - strategy: The snapshot strategy to use.
public func assertSnapshot<V: View>(
	of value: V,
	as strategy: SnapshotStrategy,
	fileID: StaticString = #fileID,
	file filePath: StaticString = #filePath,
	testName: String = #function,
	line: UInt = #line,
	column: UInt = #column
) {
	let location = SourceLocation(fileID: fileID, filePath: filePath, testName: testName, line: line, column: column)

	switch strategy {
	case .image:
		forward(of: value, as: .image, location: location)
	case .device:
		forward(of: value, as: .image(layout: .device(config: .iPhone13ProMax)), location: location)
	case .presentationLayer:
		let controller = host(value, size: snapshotDeviceSize)
		forward(of: controller.view, as: .imageOfPresentationLayer(), location: location)
	case .component(let size):
		let controller = host(value, size: size)
		forward(of: controller, as: .image, location: location)
	}
}

// MARK: - UIHostingController

/// Asserts a snapshot of a `UIHostingController`.
/// - Parameters:
///   - controller: The hosting controller to snapshot.
///   - strategy: The snapshot strategy to use.
public func assertSnapshot<V: View>(
	of controller: UIHostingController<V>,
	as strategy: SnapshotStrategy,
	fileID: StaticString = #fileID,
	file filePath: StaticString = #filePath,
	testName: String = #function,
	line: UInt = #line,
	column: UInt = #column
) {
	let location = SourceLocation(fileID: fileID, filePath: filePath, testName: testName, line: line, column: column)

	switch strategy {
	case .image:
		forward(of: controller, as: .image, location: location)
	case .device:
		forward(of: controller, as: .image(on: .iPhone13ProMax), location: location)
	case .presentationLayer:
		fatalError("presentationLayer strategy is not supported for UIHostingController. Use a SwiftUI View instead.")
	case .component:
		fatalError("component strategy is not supported for UIHostingController. Use a SwiftUI View instead.")
	}
}

// MARK: - Private

/// Device size used by `.device` and `.presentationLayer` strategies (iPhone 13 Pro Max portrait: 428×926).
private let snapshotDeviceSize = CGSize(width: 428, height: 926)

private func host<V: View>(_ value: V, size: CGSize) -> UIHostingController<V> {
	let controller = UIHostingController(rootView: value)
	let frame = CGRect(origin: .zero, size: size)
	controller.view.frame = frame
	let window = UIWindow(frame: frame)
	window.rootViewController = controller
	window.makeKeyAndVisible()
	return controller
}

private struct SourceLocation {
	let fileID: StaticString
	let filePath: StaticString
	let testName: String
	let line: UInt
	let column: UInt
}

private func forward<Value>(
	of value: Value,
	as snapshotting: Snapshotting<Value, UIImage>,
	location: SourceLocation
) {
	SnapshotTesting.assertSnapshot(
		of: value,
		as: snapshotting,
		fileID: location.fileID,
		file: location.filePath,
		testName: location.testName,
		line: location.line,
		column: location.column
	)
}
