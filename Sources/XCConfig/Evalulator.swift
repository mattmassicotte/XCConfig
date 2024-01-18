import Foundation

/// Type that can evaluate and resolve build setting configuration assignments.
public struct Evaluator {
	public init() {
	}

	/// Resolve a heirarchy of statements into a single array of assignments.
	public func resolve(statements: [Statement], for fileURL: URL) throws -> [Assignment] {
		var assignments = [Assignment]()

		for statement in statements {
			switch statement {
			case let .includeDirective(path), let .optionalIncludeDirective(path):
				let includedAssignments = try evaluateInclude(path, for: fileURL)

				assignments.append(contentsOf: includedAssignments)
			case let .assignment(assignment):
				assignments.append(assignment)
			}
		}

		return assignments
	}

	private func evaluateInclude(_ path: String, for fileURL: URL) throws -> [Assignment] {
		let url = fileURL
			.deletingLastPathComponent()
			.appendingPathComponent(path)
		let content = try String(contentsOf: url)
		let statements = Parser().parse(content)

		return try resolve(statements: statements, for: url)
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
	public func resolve(heirarchy: [[Statement]], for fileURL: URL) throws -> [Assignment] {
		let assignmentsHeirarchy = try heirarchy.map { statements in
			try resolve(statements: statements, for: fileURL)
		}

		return try resolve(heirarchy: assignmentsHeirarchy)
	}

	/// Evaluate a heirarchy of statements into a map of build settings and values.
	///
	/// Ordered from lowest to highest precedence.
	public func evaluate(heirarchy: [[Statement]], for fileURL: URL) throws -> [BuildSetting: String] {
		let assignments = try resolve(heirarchy: heirarchy, for: fileURL)

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
