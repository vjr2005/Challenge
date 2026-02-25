import Foundation
import ProjectDescription

private let swiftVersion = "6.2"
private let iosMajorVersion = "17"

/// Single source of truth for project-wide configuration.
public let projectConfig = ProjectConfig(
	appName: "Challenge",
	swiftToolsVersion: swiftVersion,
	iosMajorVersion: iosMajorVersion,
	destinations: [.iPhone, .iPad],
	developmentTarget: .iOS("\(iosMajorVersion).0"),
	baseSettings: [
		"SWIFT_VERSION": .string(swiftVersion),
		"SWIFT_STRICT_CONCURRENCY": .string("complete"),
		"SWIFT_APPROACHABLE_CONCURRENCY": .string("YES"),
		"SWIFT_DEFAULT_ACTOR_ISOLATION": .string("MainActor"),
		"ENABLE_USER_SCRIPT_SANDBOXING": .string("NO"),
	]
)

/// Absolute path to the workspace root directory.
/// Computed from `#file` (Tuist/ProjectDescriptionHelpers/Config.swift → 3 levels up).
let workspaceRoot: String = URL(fileURLWithPath: #file)
	.deletingLastPathComponent() // Config.swift
	.deletingLastPathComponent() // ProjectDescriptionHelpers
	.deletingLastPathComponent() // Tuist
	.path
