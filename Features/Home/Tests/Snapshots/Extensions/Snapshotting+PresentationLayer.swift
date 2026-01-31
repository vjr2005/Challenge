import SnapshotTesting
import UIKit

// Based on: https://github.com/airbnb/lottie-ios/blob/master/Tests/Utils/Snapshotting%2BpresentationLayer.swift
extension Snapshotting where Value == UIView, Format == UIImage {
	/// Captures an image of the input `UIView`'s `layer.presentation()`,
	/// which reflects the current state of any in-flight animations.
	static func imageOfPresentationLayer(
		precision: Float = 1,
		perceptualPrecision: Float = 1,
		traits: UITraitCollection = .init()
	) -> Snapshotting<UIView, UIImage> {
		SimplySnapshotting.image(
			precision: precision,
			perceptualPrecision: perceptualPrecision,
			scale: traits.displayScale
		)
		.pullback { (view: UIView) -> UIImage in
			let window = UIWindow()
			window.bounds = view.bounds
			window.isHidden = false
			window.addSubview(view)

			CATransaction.flush()

			guard let presentationLayer = view.layer.presentation() else {
				fatalError("Presentation layer does not exist and cannot be snapshot")
			}

			return UIGraphicsImageRenderer(bounds: view.bounds).image { context in
				presentationLayer.render(in: context.cgContext)
			}
		}
	}
}
