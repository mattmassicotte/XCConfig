import XCTest
import XCConfig

final class EvaluatorTests: XCTestCase {
	func testEvaluateIncludedFile() throws {
		let evaluator = Evaluator()
		let url = try Bundle.module.testDataURL(named: "2.xcconfig")

		let assignments = try evaluator.resolve(contentsOf: url)
		let values = try evaluator.evaluate(assignments)

		let expected: [BuildSetting : String] = [
			BuildSetting(rawValue: "ENABLE_HARDENED_RUNTIME")! : "YES"
		]

		XCTAssertEqual(values, expected)
	}

	func testEvaluateSubdirectoryIncludedFile() throws {
		let evaluator = Evaluator()
		let url = try Bundle.module.testDataURL(named: "3.xcconfig")

		let assignments = try evaluator.resolve(contentsOf: url)
		let values = try evaluator.evaluate(assignments)

		let expected: [BuildSetting : String] = [
			BuildSetting(rawValue: "ENABLE_HARDENED_RUNTIME")! : "NO"
		]

		XCTAssertEqual(values, expected)
	}

	func testEvaluateParentDirectoryIncludedFile() throws {
		let evaluator = Evaluator()
		let url = try Bundle.module.testDataURL(named: "A/A3.xcconfig")

		let assignments = try evaluator.resolve(contentsOf: url)
		let values = try evaluator.evaluate(assignments)

		let expected: [BuildSetting : String] = [
			BuildSetting(rawValue: "ENABLE_HARDENED_RUNTIME")! : "YES"
		]

		XCTAssertEqual(values, expected)
	}
}

extension EvaluatorTests {
	func testPlatformDefaults() throws {
		let evaluator = Evaluator()
		let heirarchy = BuildSettingsHeirarchy(
			platformDefaults: [.init(key: "ACTION", value: "HELLO")],
			projectConfigURL: nil,
			project: [],
			configURL: nil,
			target: []
		)

		let values = try evaluator.evaluate(heirarchy)

		let expected: [BuildSetting : String] = [
			BuildSetting(rawValue: "ACTION")! : "HELLO"
		]

		XCTAssertEqual(values, expected)
	}

	func testProjectPrecedence() throws {
		let evaluator = Evaluator()
		let heirarchy = BuildSettingsHeirarchy(
			platformDefaults: [.init(key: "ACTION", value: "HELLO")],
			projectConfigURL: nil,
			project: [.init(key: "ACTION", value: "GOODBYE")],
			configURL: nil,
			target: []
		)

		let values = try evaluator.evaluate(heirarchy)

		let expected: [BuildSetting : String] = [
			BuildSetting(rawValue: "ACTION")! : "GOODBYE"
		]

		XCTAssertEqual(values, expected)
	}

	func testTargetFileOverridingProject() throws {
		let evaluator = Evaluator()
		let heirarchy = BuildSettingsHeirarchy(
			platformDefaults: [],
			projectConfigURL: try Bundle.module.testDataURL(named: "A/A1.xcconfig"),
			project: [],
			configURL: try Bundle.module.testDataURL(named: "1.xcconfig"),
			target: []
		)

		let values = try evaluator.evaluate(heirarchy)

		let expected: [BuildSetting : String] = [
			BuildSetting(rawValue: "ENABLE_HARDENED_RUNTIME")! : "YES"
		]

		XCTAssertEqual(values, expected)
	}

	func testTargetFileOverridingProjectWithInclude() throws {
		let evaluator = Evaluator()
		let heirarchy = BuildSettingsHeirarchy(
			platformDefaults: [],
			projectConfigURL: try Bundle.module.testDataURL(named: "3.xcconfig"),
			project: [],
			configURL: try Bundle.module.testDataURL(named: "1.xcconfig"),
			target: []
		)

		let values = try evaluator.evaluate(heirarchy)

		let expected: [BuildSetting : String] = [
			BuildSetting(rawValue: "ENABLE_HARDENED_RUNTIME")! : "YES"
		]

		XCTAssertEqual(values, expected)
	}
}
