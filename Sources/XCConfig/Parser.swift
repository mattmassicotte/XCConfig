/// Describes a variable conditional
///
/// An example conditional is the stuff enclosed in brackets here "MY_VARIABLE[sdk=iphone*]"
public struct Condition: Hashable, Sendable {
	public enum Key: Hashable, Sendable {
        case sdk
        case config
        case arch
    }

    let key: Key
    let value: String
}

/// Values both on the left and right sides of an assignment statement
public enum Value: Hashable, Sendable {
    case string(String)
    indirect case substitution(Value, default: String?)
    case composition([Value])
}

extension Value: ExpressibleByStringLiteral {
	public init(stringLiteral value: String) {
		self = .string(value)
	}
}

/// Represents the statements in a xcconfig file
public enum Statement: Hashable, Sendable {
    case includeDirective(String)
    case optionalIncludeDirective(String)
    case assignment(Value, Value, conditions: [Condition] = [])
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

	private func parseAssigment(_ input: String) -> Statement? {
		let components = input.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: true)

		guard components.count == 2 else {
			return nil
		}

		let lhs = String(components[0]).trimmingCharacters(in: .whitespaces)
		let rhs = String(components[1]).trimmingCharacters(in: .whitespaces)

		return Statement.assignment(.string(lhs), .string(rhs))
	}

	private func parseInclude(_ input: String) -> Statement? {
		// this is very not good

		guard let quoteIndex = input.firstIndex(of: "\"") else {
			return nil
		}

		let start = input.index(after: quoteIndex)
		let end = input.index(before: input.endIndex)

		let content = input[start..<end]

		return .includeDirective(String(content))
	}
}
