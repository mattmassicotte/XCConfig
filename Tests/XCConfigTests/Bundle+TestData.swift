import Foundation
import XCTest

extension Bundle {
	var testDataURL: URL {
		resourceURL!.appendingPathComponent("TestData", isDirectory: true)
	}
	
	func testDataURL(named: String) throws -> URL {
		let resourceURL = try XCTUnwrap(resourceURL)

		return resourceURL
			.appendingPathComponent("TestData", isDirectory: true)
			.appendingPathComponent(named)
			.standardizedFileURL
	}
}
