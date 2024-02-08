import XCTest
@testable import XCConfig

final class ParserTests: XCTestCase {
    func testEmptyFile() throws {
        let input = """
"""

		let output = Parser().parse(input)
		let expected: [Statement] = [
		]

		XCTAssertEqual(output, expected)
    }

    func testKeyValue() throws {
        let input = """
HELLO = world
"""

		let output = Parser().parse(input)
		let expected: [Statement] = [
			.assignment(Assignment(key: "HELLO", value: "world"))
		]

		XCTAssertEqual(output, expected)
    }

	func testComments() throws {
		let input = """
// blah
HELLO = world
"""

		let output = Parser().parse(input)
		let expected: [Statement] = [
			.assignment(Assignment(key: "HELLO", value: "world"))
		]

		XCTAssertEqual(output, expected)
	}

    func testSimpleInclude() throws {
        let input = """
#include "other.xcconfig"
"""

		let output = Parser().parse(input)
		let expected: [Statement] = [
			.includeDirective("other.xcconfig")
		]

		XCTAssertEqual(output, expected)
    }

	func testOptionalInclude() throws {
		let input = """
#include? "other.xcconfig"
"""

		let output = Parser().parse(input)
		let expected: [Statement] = [
			.optionalIncludeDirective("other.xcconfig")
		]

		XCTAssertEqual(output, expected)
	}
}
