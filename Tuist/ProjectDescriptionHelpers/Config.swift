import Foundation
import ProjectDescription

public let appName = "Challenge"

/// Absolute path to the workspace root directory.
/// Computed from `#file` (Tuist/ProjectDescriptionHelpers/Config.swift → 3 levels up).
public let workspaceRoot: String = URL(fileURLWithPath: #file)
	.deletingLastPathComponent() // Config.swift
	.deletingLastPathComponent() // ProjectDescriptionHelpers
	.deletingLastPathComponent() // Tuist
	.path

public let swiftVersion = "6.2"

public let developmentTarget: DeploymentTargets = .iOS("17.0")

public let destinations: ProjectDescription.Destinations = [.iPhone, .iPad]

/// Base project-level build settings shared across all projects (main app and standalone modules).
public let projectBaseSettings: SettingsDictionary = [
	"SWIFT_VERSION": .string(swiftVersion),
	"SWIFT_APPROACHABLE_CONCURRENCY": .string("YES"),
	"SWIFT_DEFAULT_ACTOR_ISOLATION": .string("MainActor"),
	"ENABLE_USER_SCRIPT_SANDBOXING": .string("NO"),
]
