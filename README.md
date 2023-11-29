<div align="center">

[![Build Status][build status badge]][build status]

</div>

# XCConfig
xcconfig file parsing and evaluation

This kinda works, but is quite limited.

## Integration

```swift
dependencies: [
    .package(url: "https://github.com/mattmassicotte/XCConfig", branch: "main")
]
```

## Usage

```swift
import XCConfig

let input = """
HELLO = world
"""

let output = Parser().parse(input)
```

## Alternatives

- (regexident/XCConfig)[https://github.com/regexident/XCConfig]

## Contributing and Collaboration

I'd love to hear from you! Get in touch via [mastodon](https://mastodon.social/@mattiem), an issue, or a pull request.

I prefer collaboration, and would love to find ways to work together if you have a similar project.

I prefer indentation with tabs for improved accessibility. But, I'd rather you use the system you want and make a PR than hesitate because of whitespace.

By participating in this project you agree to abide by the [Contributor Code of Conduct](CODE_OF_CONDUCT.md).

[build status]: https://github.com/mattmassicotte/XCConfig/actions
[build status badge]: https://github.com/mattmassicotte/XCConfig/workflows/CI/badge.svg
