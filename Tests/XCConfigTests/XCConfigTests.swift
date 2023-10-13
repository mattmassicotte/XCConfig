import XCTest
@testable import XCConfig

final class XCConfigTests: XCTestCase {
    func testEmptyFile() throws {
        let input = """
"""
    }

    func testKeyValue() throws {
        let input = """
HELLO = world
"""
    }

    func testSimpleInclude() throws {
        let input = """
#include "other.xcconfig"
"""
    }

    func testComments() throws {
        let input = """
// blah
HELLO = world
"""
    }
}
