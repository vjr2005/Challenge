import Foundation

/// Absolute path to the workspace root directory.
///
/// Walks up from `#file` until the `Tuist` directory is found,
/// then returns the parent (workspace root). This approach is robust
/// regardless of file depth within `Tuist/ProjectDescriptionHelpers/`.
let workspaceRoot: String = {
	var url = URL(fileURLWithPath: #file)
	while url.lastPathComponent != "Tuist", url.path != "/" {
		url = url.deletingLastPathComponent()
	}
	return url.deletingLastPathComponent().path
}()
