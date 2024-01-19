import Foundation


public struct BuildSettingsHeirarchy {
	public let projectRootURL: URL
	public let platformDefaults: [Assignment]
	public let projectConfigURL: URL?
	public let project: [Assignment]
	public let configURL: URL?
	public let target: [Assignment]

	public init(
		projectRootURL: URL,
		platformDefaults: [Assignment],
		projectConfigURL: URL?,
		project: [Assignment],
		configURL: URL?,
		target: [Assignment]
	) {
		self.projectRootURL = projectRootURL
		self.platformDefaults = platformDefaults
		self.projectConfigURL = projectConfigURL
		self.project = project
		self.configURL = configURL
		self.target = target
	}
}

/// Type that can evaluate and resolve build setting configuration assignments.
///
/// Terminology:
/// - "resolve": transform values into `Assignment`
/// - "evaluate": transform `Assignment` into `[BuildSetting: String]`
public struct Evaluator {
	public init() {
	}

	/// Resolve the contents of an xcconfifg file into an array of `Assignment`.
	public func resolve(contentsOf url: URL, projectRoot: URL) throws -> [Assignment] {
		var assignments = [Assignment]()

		let statements = try Parser().parse(contentsOf: url)

		for statement in statements {
			switch statement {
			case let .includeDirective(path):
				let includedAssignments = try resolveInclude(path, for: url, rootURL: projectRoot)

				assignments.append(contentsOf: includedAssignments)
			case let .optionalIncludeDirective(path):
				let includedAssignments = (try? resolveInclude(path, for: url, rootURL: projectRoot)) ?? []

				assignments.append(contentsOf: includedAssignments)
			case let .assignment(assignment):
				assignments.append(assignment)
			}
		}

		return assignments
	}

	public func evaluate(_ assignments: [Assignment]) throws -> [BuildSetting: String] {
		var settings = [BuildSetting: String]()

		for assignment in assignments {
			guard let setting = BuildSetting(rawValue: assignment.key.description) else {
				continue
			}

			let value = assignment.value.description

			settings[setting] = value
		}

		return settings
	}

	/// Xcode's documentation (https://developer.apple.com/documentation/xcode/adding-a-build-configuration-file-to-your-project) says that this will always look up paths relative to the current file. However, it seems like if that fails, it will fall back to using the project root.
	private func resolveInclude(_ path: String, for fileURL: URL, rootURL: URL) throws -> [Assignment] {
		// first, try file-relative
		let fileRelativeURL = fileURL
			.deletingLastPathComponent()
			.appendingPathComponent(path)

		if FileManager.default.isReadableFile(atPath: fileRelativeURL.path) {
			return try resolve(contentsOf: fileRelativeURL, projectRoot: rootURL)
		}

		let rootRelativeURL = rootURL
			.appendingPathComponent(path)

		if FileManager.default.isReadableFile(atPath: rootRelativeURL.path) {
			return try resolve(contentsOf: rootRelativeURL, projectRoot: rootURL)
		}

		let absoluteURL = URL(fileURLWithPath: path)

		return try resolve(contentsOf: absoluteURL, projectRoot: rootURL)
	}

	/// Evaluate a heirarchy of setting entries into a single array.
	public func evaluate(_ heirarchy: BuildSettingsHeirarchy) throws -> [BuildSetting: String] {
		var assignments = heirarchy.platformDefaults
		let root = heirarchy.projectRootURL

		let projectAssignments = try heirarchy.projectConfigURL.map { try resolve(contentsOf: $0, projectRoot: root) } ?? []

		assignments.append(contentsOf: projectAssignments)
		assignments.append(contentsOf: heirarchy.project)

		let configAssignments = try heirarchy.configURL.map { try resolve(contentsOf: $0, projectRoot: root) } ?? []

		assignments.append(contentsOf: configAssignments)
		assignments.append(contentsOf: heirarchy.target)

		return try evaluate(assignments)
	}
}
