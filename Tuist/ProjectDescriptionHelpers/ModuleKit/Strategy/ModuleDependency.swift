import ProjectDescription

/// A dependency reference for module configuration.
///
/// Used in module init parameters to declare dependencies on other modules
/// or external SPM packages.
public enum ModuleDependency {
	/// Dependency on a module's main source target.
	case module(any ModuleContract)

	/// Dependency on a module's mocks target.
	case moduleMocks(any ModuleContract)

	/// Dependency on an external SPM package product.
	case external(ExternalPackage)
}

// MARK: - Target Resolution

extension ModuleDependency {
	/// Resolves the dependency to a `TargetDependency`.
	var targetDependency: TargetDependency {
		switch self {
		case let .module(module):
			module.targetDependency
		case let .moduleMocks(module):
			module.mocksTargetDependency
		case let .external(package):
			.external(name: package.productName)
		}
	}
}
