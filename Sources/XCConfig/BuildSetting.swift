import Foundation

public enum BuildSettingValue {
	case set(Set<String>, deprecated: Set<String> = Set())

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

public enum BuildSettingValueStatus {
	case valid
	case invalid
	case deprecated
}

/// Xcode build settings.
///
/// Defined by the reference at https://developer.apple.com/documentation/xcode/build-settings-reference
public enum BuildSetting: String {
	case alwaysSearchUserPaths = "ALWAYS_SEARCH_USER_PATHS"
}

extension BuildSetting {
	public var permittedValue: BuildSettingValue {
		switch self {
		case .alwaysSearchUserPaths: .set(["NO"], deprecated: ["YES"])
		}
	}

	public func evaluateValue(_ string: String) -> BuildSettingValueStatus {
		permittedValue.evaluateValue(string)
	}
}
