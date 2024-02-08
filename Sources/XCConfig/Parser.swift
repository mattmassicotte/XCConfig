import Foundation

/// Describes a variable conditional
///
/// An example conditional is the stuff enclosed in brackets here "MY_VARIABLE[sdk=iphone*]"
public enum ConditionKey: Hashable, Sendable {
	case sdk
	case config
	case arch
}

/// Values both on the left and right sides of an assignment statement
public enum Value: Hashable, Sendable {
    case string(String)
    indirect case substitution(Value, default: String?)
    case composition([Value])
}

extension Value: CustomStringConvertible {
	public var description: String {
		switch self {
		case let .string(value):
			value
		case let .composition(values):
			values.map({ $0.description }).joined(separator: " ")
		case let .substitution(value, default: _):
			"$(\(value.description))"
		}
	}
}

extension Value: ExpressibleByStringLiteral {
	public init(stringLiteral value: String) {
		self = .string(value)
	}
}

/// A variable value assignment
public struct Assignment: Hashable, Sendable {
	public let key: Value
	public let value: Value
	public let conditions: [ConditionKey: String]

	public init(key: Value, value: Value, conditions: [ConditionKey: String] = [:]) {
		self.key = key
		self.value = value
		self.conditions = conditions
	}

	public init(key: String, value: String, conditions: [ConditionKey: String] = [:]) {
		self.key = .string(key)
		self.value = .string(value)
		self.conditions = conditions
	}
}

extension Assignment: CustomStringConvertible {
	public var description: String {
		"\(key) = \(value)"
	}
}

/// Represents the statements in a xcconfig file
public enum Statement: Hashable, Sendable {
    case includeDirective(String)
    case optionalIncludeDirective(String)
	case assignment(Assignment)
}

public struct Parser {
	public init() {
	}

	public func parse(_ input: String) -> [Statement] {
		var statements = [Statement]()

		let lines = input.split(separator: "\n")

		for line in lines {
			let trimmedLine = line.trimmingCharacters(in: .whitespaces)

			// ignore comments
			if trimmedLine.hasPrefix("//") {
				continue
			}

			if trimmedLine.hasPrefix("#include") {
				if let stmt = parseInclude(trimmedLine) {
					statements.append(stmt)
				}

				continue
			}

			if let stmt = parseAssigment(trimmedLine) {
				statements.append(stmt)

				continue
			}
		}

		return statements
	}

	public func parse(contentsOf url: URL) throws -> [Statement] {
		let string = try String(contentsOf: url)

		return parse(string)
	}

	private func parseAssigment(_ input: String) -> Statement? {
		let components = input.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: true)

		guard components.count == 2 else {
			return nil
		}

		let lhs = String(components[0]).trimmingCharacters(in: .whitespaces)
		let rhs = String(components[1]).trimmingCharacters(in: .whitespaces)
		let assignment = Assignment(key: lhs, value: rhs)

		return Statement.assignment(assignment)
	}

	private func parseInclude(_ input: String) -> Statement? {
		// this is very not good

		guard let quoteIndex = input.firstIndex(of: "\"") else {
			return nil
		}

		let start = input.index(after: quoteIndex)
		let end = input.index(before: input.endIndex)

		let content = input[start..<end]
		let string = String(content)

		let optional = input.hasPrefix("#include?")

		return optional ? .optionalIncludeDirective(string) : .includeDirective(string)
	}
}
