import Foundation

/// Type that can evaluate and resolve build setting configuration assignments.
public struct Evaluator {
	public let rootURL: URL

	public init(rootURL: URL) {
		self.rootURL = rootURL
	}

	/// Resolve a heirarchy of statements into a single array of assignments.
	public func resolve(statements: [Statement]) throws -> [Assignment] {
		statements.compactMap { statement -> Assignment? in
			switch statement {
			case .includeDirective, .optionalIncludeDirective:
				print("xcconfig includes unsupported")
				return nil
			case let .assignment(assignment):
				return assignment
			}
		}
	}

	/// Resolve a heirarchy of assignments into a single array.
	///
	/// Ordered from lowest to highest precedence.
	public func resolve(heirarchy: [[Assignment]]) throws -> [Assignment] {
		var resolved = [String: Assignment]()

		for assignments in heirarchy {
			for assignment in assignments {
				switch assignment.key {
				case let .string(name):
					resolved[name] = assignment
				case .composition, .substitution:
					print("unhandled complex base settings")
				}
			}
		}

		return Array(resolved.values)
	}

	/// Reduce a heirarchy of statements into a single assignment array.
	///
	/// Ordered from lowest to highest precedence.
	public func resolve(heirarchy: [[Statement]]) throws -> [Assignment] {
		let assignmentsHeirarchy = try heirarchy.map { statements in
			try resolve(statements: statements)
		}

		return try resolve(heirarchy: assignmentsHeirarchy)
	}

	/// Evaluate a heirarchy of statements into a map of build settings and values.
	///
	/// Ordered from lowest to highest precedence.
	public func evaluate(heirarchy: [[Statement]]) throws -> [BuildSetting: String] {
		let assignments = try resolve(heirarchy: heirarchy)

		var settings = [BuildSetting: String]()

		for assignment in assignments {
			guard let setting = BuildSetting(rawValue: assignment.key.description) else {
				continue
			}

			let value = assignment.value.description

			settings[setting] = value
		}

		return settings
	}
}
