import XCTest
import XCConfig

final class EvaluatorTests: XCTestCase {
	func testEvaluateIncludedFile() throws {
		let url = try Bundle.module.testDataURL(named: "File.xcconfig")
		let contents = try String(contentsOf: url)

		let statements = Parser().parse(contents)

		let rootURL = url.deletingLastPathComponent()

		let evaluator = Evaluator(rootURL: rootURL)

		let values = try evaluator.evaluate(heirarchy: [statements])

		let expected: [BuildSetting : String] = [
			BuildSetting(rawValue: "ENABLE_HARDENED_RUNTIME")! : "YES"
		]

		XCTAssertEqual(values, expected)
	}
}
