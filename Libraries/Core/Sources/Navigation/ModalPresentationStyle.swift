import SwiftUI

/// Defines how a modal navigation should be presented.
public enum ModalPresentationStyle: Hashable {
    /// Presents as a sheet with the specified detents.
    case sheet(detents: Set<PresentationDetent> = [.large])

    /// Presents as a full-screen cover.
    case fullScreenCover
}
