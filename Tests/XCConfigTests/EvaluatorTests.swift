import XCTest
import XCConfig

final class EvaluatorTests: XCTestCase {
	func testEvaluateIncludedFile() throws {
		let url = try Bundle.module.testDataURL(named: "2.xcconfig")
		let contents = try String(contentsOf: url)

		let statements = Parser().parse(contents)
		let evaluator = Evaluator()

		let values = try evaluator.evaluate(heirarchy: [statements], for: url)

		let expected: [BuildSetting : String] = [
			BuildSetting(rawValue: "ENABLE_HARDENED_RUNTIME")! : "YES"
		]

		XCTAssertEqual(values, expected)
	}

	func testEvaluateSubdirectoryIncludedFile() throws {
		let url = try Bundle.module.testDataURL(named: "3.xcconfig")
		let contents = try String(contentsOf: url)

		let statements = Parser().parse(contents)
		let evaluator = Evaluator()

		let values = try evaluator.evaluate(heirarchy: [statements], for: url)

		let expected: [BuildSetting : String] = [
			BuildSetting(rawValue: "ENABLE_HARDENED_RUNTIME")! : "NO"
		]

		XCTAssertEqual(values, expected)
	}

	func testEvaluateParentDirectoryIncludedFile() throws {
		let url = try Bundle.module.testDataURL(named: "A/A3.xcconfig")
		let contents = try String(contentsOf: url)

		let statements = Parser().parse(contents)

		let evaluator = Evaluator()

		let values = try evaluator.evaluate(heirarchy: [statements], for: url)

		let expected: [BuildSetting : String] = [
			BuildSetting(rawValue: "ENABLE_HARDENED_RUNTIME")! : "YES"
		]

		XCTAssertEqual(values, expected)
	}
}
