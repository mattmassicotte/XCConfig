import Foundation

public enum BuildSettingValue: Hashable, Sendable {
	case set(Set<String>, deprecated: Set<String> = Set())

	public static let boolean = BuildSettingValue.set(["NO", "YES"])

	public func evaluateValue(_ string: String) -> BuildSettingValueStatus {
		switch self {
		case let .set(validSet, deprecated: deprecatedSet):
			if deprecatedSet.contains(string) {
				return .deprecated
			}

			return validSet.contains(string) ? .valid : .invalid
		}
	}
}

public enum BuildSettingValueStatus: Hashable, Sendable {
	case valid
	case invalid
	case deprecated
}

/// Xcode build settings.
///
/// Defined by the reference at https://developer.apple.com/documentation/xcode/build-settings-reference
public enum BuildSetting: String, Sendable {
	case alwaysSearchUserPaths = "ALWAYS_SEARCH_USER_PATHS"
	case enableHardenedRuntime = "ENABLE_HARDENED_RUNTIME"
}

extension BuildSetting {
	public var permittedValue: BuildSettingValue {
		switch self {
		case .alwaysSearchUserPaths: .set(["NO"], deprecated: ["YES"])
		case .enableHardenedRuntime: .boolean
		}
	}

	public func evaluateValue(_ string: String) -> BuildSettingValueStatus {
		permittedValue.evaluateValue(string)
	}
}
