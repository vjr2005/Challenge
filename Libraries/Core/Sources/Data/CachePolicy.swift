import Foundation

/// Policy for controlling cache behavior when fetching data.
nonisolated public enum CachePolicy {
	/// Cache first, remote if not found. Default behavior.
	case localFirst

	/// Remote first, cache as fallback on error.
	case remoteFirst

	/// Only remote, no cache interaction.
	case noCache
}
