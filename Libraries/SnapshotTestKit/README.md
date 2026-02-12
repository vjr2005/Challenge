# ChallengeSnapshotTestKit

Snapshot testing framework for the project. Provides a **black-box API** that abstracts the underlying snapshot library, so that consumers (test targets) never depend on it directly.

## Structure

```
SnapshotTestKit/
└── Sources/
    ├── SnapshotTestKit.swift
    └── Snapshotting+PresentationLayer.swift
```

## Why this module exists

- **Single point of change.** If the underlying snapshot library is replaced, only this module needs to be updated. No test file, documentation, or skill outside this module should reference the internal library.
- **Simplified API.** Tests use a small, domain-specific API (`SnapshotStrategy`) instead of dealing with library-specific types and configurations.
- **Consistent device configuration.** The `.device` strategy always uses iPhone 13 Pro Max (428x926), ensuring all full-screen snapshots are rendered at the same size.

## Underlying library

This module wraps [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) by [Point-Free](https://www.pointfree.co/).

## Public API

### `SnapshotStrategy`

```swift
public enum SnapshotStrategy {
    case image                                    // Intrinsic size (.sizeThatFits). For components.
    case device                                   // iPhone 13 Pro Max (428x926). For full-screen views.
    case presentationLayer                        // Captures layer.presentation(). For animated views (Lottie).
    case component(size: CGSize)                    // Explicit dimensions inside a UIWindow. For components that need a real view hierarchy.
}
```

### `assertSnapshot` overloads

| Overload | Input type | Supported strategies |
|----------|-----------|---------------------|
| `assertSnapshot(of:as:)` | `some View` | `.image`, `.device`, `.presentationLayer`, `.component` |
| `assertSnapshot(of:as:)` | `UIHostingController` | `.image`, `.device` |

All overloads propagate `fileID`, `filePath`, `testName`, `line`, and `column` so that snapshot file paths and failure locations point to the calling test.

## Usage

```swift
import ChallengeSnapshotTestKit

// Component snapshot (intrinsic size)
assertSnapshot(of: myComponent, as: .image)

// Full-screen snapshot
assertSnapshot(of: myScreen, as: .device)

// Animated view snapshot (Lottie, etc.)
assertSnapshot(of: myAnimatedView, as: .presentationLayer)

// Component that wraps a Button (needs a real view hierarchy)
assertSnapshot(of: myChip.padding(), as: .component(size: CGSize(width: 200, height: 60)))
```
