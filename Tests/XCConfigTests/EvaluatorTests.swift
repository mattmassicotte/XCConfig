import XCTest
import XCConfig

final class EvaluatorTests: XCTestCase {
	func testEvaluateIncludedFile() throws {
		let evaluator = Evaluator()
		let root = Bundle.module.testDataURL.appendingPathComponent("SingleFile")
		let url = root.appendingPathComponent("Target.xcconfig")

		let assignments = try evaluator.resolve(contentsOf: url, projectRoot: root)
		let values = try evaluator.evaluate(assignments)

		let expected: [BuildSetting : String] = [
			BuildSetting(rawValue: "ENABLE_HARDENED_RUNTIME")! : "YES"
		]

		XCTAssertEqual(values, expected)
	}

	func testEvaluateSubdirectoryIncludedFile() throws {
		let evaluator = Evaluator()
		let root = Bundle.module.testDataURL.appendingPathComponent("SubdirectoryInclude")
		let url = root.appendingPathComponent("Target.xcconfig")

		let assignments = try evaluator.resolve(contentsOf: url, projectRoot: root)
		let values = try evaluator.evaluate(assignments)

		let expected: [BuildSetting : String] = [
			BuildSetting(rawValue: "ENABLE_HARDENED_RUNTIME")! : "NO"
		]

		XCTAssertEqual(values, expected)
	}

	func testEvaluateRelativeDirectoryIncludedFile() throws {
		let evaluator = Evaluator()
		let root = Bundle.module.testDataURL.appendingPathComponent("RelativeDirectoryInclude")
		let url = root.appendingPathComponent("A/Target.xcconfig")

		let assignments = try evaluator.resolve(contentsOf: url, projectRoot: root)
		let values = try evaluator.evaluate(assignments)

		let expected: [BuildSetting : String] = [
			BuildSetting(rawValue: "ENABLE_HARDENED_RUNTIME")! : "NO"
		]

		XCTAssertEqual(values, expected)
	}

	func testEvaluateRootRelativeDirectoryIncludedFile() throws {
		let evaluator = Evaluator()
		let root = Bundle.module.testDataURL.appendingPathComponent("RootRelativeDirectoryInclude")
		let url = root.appendingPathComponent("A/Target.xcconfig")

		let assignments = try evaluator.resolve(contentsOf: url, projectRoot: root)
		let values = try evaluator.evaluate(assignments)

		let expected: [BuildSetting : String] = [
			BuildSetting(rawValue: "ENABLE_HARDENED_RUNTIME")! : "NO"
		]

		XCTAssertEqual(values, expected)
	}
}

extension EvaluatorTests {
	func testPlatformDefaults() throws {
		let evaluator = Evaluator()
		let heirarchy = BuildSettingsHeirarchy(
			projectRootURL: URL(fileURLWithPath: "/"),
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
			projectRootURL: URL(fileURLWithPath: "/"),
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
		let root = Bundle.module.testDataURL.appendingPathComponent("TargetOverride")
		let heirarchy = BuildSettingsHeirarchy(
			projectRootURL: root,
			platformDefaults: [],
			projectConfigURL: root.appendingPathComponent("Project.xcconfig"),
			project: [],
			configURL: root.appendingPathComponent("Target.xcconfig"),
			target: []
		)

		let values = try evaluator.evaluate(heirarchy)

		let expected: [BuildSetting : String] = [
			BuildSetting(rawValue: "ENABLE_HARDENED_RUNTIME")! : "YES"
		]

		XCTAssertEqual(values, expected)
	}

	func testTargetFileMissingOptionalInclude() throws {
		let evaluator = Evaluator()
		let root = Bundle.module.testDataURL.appendingPathComponent("MissingOptionalInclude")
		let heirarchy = BuildSettingsHeirarchy(
			projectRootURL: root,
			platformDefaults: [],
			projectConfigURL: nil,
			project: [],
			configURL: root.appendingPathComponent("Target.xcconfig"),
			target: []
		)

		let values = try evaluator.evaluate(heirarchy)

		let expected: [BuildSetting : String] = [
			BuildSetting(rawValue: "ENABLE_HARDENED_RUNTIME")! : "YES"
		]

		XCTAssertEqual(values, expected)
	}
}
