/// Describes a variable conditional
///
/// An example conditional is the stuff enclosed in brackets here "MY_VARIABLE[sdk=iphone*]"
public struct Condition {
    public enum Key {
        case sdk
        case config
        case arch
    }

    let key: Key
    let value: String
}

/// Values both on the left and right sides of an assignment statement
public enum Value {
    case string(String)
    indirect case substitution(Value, default: String?)
    case composition([Value])
}

/// Represents the statements in a xcconfig file
public enum Statement {
    case includeDirective(String)
    case optionalIncludeDirective(String)
    case assignment(Value, Value, conditions: [Condition])
}
