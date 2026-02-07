import Foundation

/// Policy for controlling cache behavior when fetching data.
public enum CachePolicy: Sendable {
	/// Cache first, remote if not found. Default behavior.
	case localFirst

	/// Remote first, cache as fallback on error.
	case remoteFirst

	/// Only remote, no cache interaction.
	case noCache
}
