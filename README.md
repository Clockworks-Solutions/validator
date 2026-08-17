![A powerful, type-safe validation framework for Swift](https://raw.githubusercontent.com/Clockworks-Solutions/validator/main/Resources/validator.png)

<h1 align="center" style="margin-top: 0px;">validator</h1>

<p align="center">
<a href="https://github.com/Clockworks-Solutions/validator/blob/main/LICENSE"><img alt="Licence" src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat"></a>
<a href="https://swift.org"><img alt="Swift Compatibility" src="https://img.shields.io/badge/Swift-6.1-orange.svg?style=flat"></a>
<img alt="Platform Compatibility" src="https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20visionOS%20%7C%20Android-lightgrey.svg?style=flat">
<a href="https://github.com/apple/swift-package-manager" alt="Validator on Swift Package Manager" title="Validator on Swift Package Manager"><img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" /></a>
<a href="https://skip.tools"><img alt="Skip" src="https://img.shields.io/badge/Skip-compatible-8A2BE2.svg?style=flat"></a>
</p>

> **This is a fork.**
> Upstream: [space-code/validator](https://github.com/space-code/validator), created and maintained by Nikita Vasilev.
> This fork is maintained by [Clockworks Solutions](https://github.com/Clockworks-Solutions/validator) and extends the
> original with support for [Skip](https://skip.tools), so the same validation code runs on Apple platforms **and** on
> Android. Issues, discussions and pull requests for this fork belong
> [here](https://github.com/Clockworks-Solutions/validator) — please do not file fork-specific reports upstream.

## Description

Validator is a modern, lightweight Swift framework that provides elegant and type-safe input validation. Built with Swift's powerful type system, it integrates with SwiftUI, UIKit and AppKit, making form validation effortless across Apple platforms — and, through Skip, on Android from the very same Swift source.

## Features

✨ **Type-Safe Validation** - Leverages Swift's type system for compile-time safety  
🎯 **Rich Rule Set** - Built-in validators for common use cases  
🔧 **Extensible** - Easy to create custom validation rules  
🤖 **Android via Skip** - `ValidatorCore` and the SwiftUI layer compile natively for Android  
🎨 **SwiftUI Native** - Property wrappers and view modifiers for declarative validation  
👀 **Observation-Based** - Form state is driven by `@Observable`, not Combine, so it works on every platform  
📱 **UIKit & AppKit Integration** - First-class support for `UITextField`, `UITextView` and `NSTextField` (Apple only)  
📋 **Form Management** - Validate multiple fields with centralized state management  
🧪 **Well Tested** - Comprehensive test coverage  

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Skip Integration](#skip-integration)
- [Quick Start](#quick-start)
- [Usage](#usage)
  - [Core Validation](#core-validation)
  - [UIKit Integration](#uikit-integration)
  - [SwiftUI Integration](#swiftui-integration)
  - [Form Validation](#form-validation)
- [Built-in Validators](#built-in-validators)
- [Custom Validators](#custom-validators)
- [Examples](#examples)
- [Communication](#communication)
- [Contributing](#contributing)
    - [Development Setup](#development-setup)
    - [Code of Conduct](#code-of-conduct)
- [License](#license)

## Requirements

| Platform  | Minimum Version    |
|-----------|--------------------|
| iOS       | 17.0+              |
| macOS     | 14.0+              |
| tvOS      | 17.0+              |
| watchOS   | 10.0+              |
| visionOS  | 1.0+               |
| Android   | API 28+ (via Skip) |
| Xcode     | 16.3+              |
| Swift     | 6.1+               |

The floor is higher than upstream for two reasons: the form-validation stack is built on `Observation`, and the
package depends on `skip-fuse-ui`, which itself requires iOS 17 / macOS 14.

> **Note:** the [Skip](https://skip.tools) toolchain (`brew install skiptools/skip/skip`) is required to build this
> package on every platform, not just for Android, because the `skipstone` plugin runs as part of the build.

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Clockworks-Solutions/validator.git", branch: "main")
]
```

Or add it through Xcode:

1. File > Add Package Dependencies
2. Enter package URL: `https://github.com/Clockworks-Solutions/validator.git`
3. Select version requirements

The package pulls in `skip`, `skip-fuse` and `skip-fuse-ui` transitively; in a Skip app these are the same
dependencies your app already resolves.

## Skip Integration

[Skip](https://skip.tools) compiles Swift for Android. This fork is a Skip **Fuse** package: the Swift sources are
compiled natively for Android, and the `skipstone` plugin generates the Kotlin bridge so the SwiftUI layer renders
through Jetpack Compose.

What that means in practice:

- **`ValidatorCore` is fully portable.** Every rule works identically on Apple platforms and Android.
- **The SwiftUI layer is portable.** `import SkipFuseUI` re-exports real SwiftUI on Apple platforms and Skip's
  SwiftUI implementation on Android, so the library has a single code path.
- **Form state uses `Observation`.** `Combine` does not exist in the Android Swift SDK; `@Observable` does, and Skip
  bridges its property reads and writes into Compose's snapshot system.
- **UIKit and AppKit helpers are Apple-only.** They attach state to `UITextField`/`NSTextField` through the
  Objective-C runtime, which has no Android equivalent. They are compiled out there; use the SwiftUI API instead.

Nothing extra is required in your app — add the package to a Skip target and build:

```swift
.target(
    name: "MyFeature",
    dependencies: [
        .product(name: "ValidatorUI", package: "validator"),
    ],
    plugins: [.plugin(name: "skipstone", package: "skip")]
)
```

## Quick Start

```swift
import ValidatorCore

let validator = Validator()
let result = validator.validate(
    input: "user@example.com",
    rule: RegexValidationRule(
        pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}",
        error: "Invalid email address"
    )
)

switch result {
case .valid:
    print("✅ Valid input")
case .invalid(let errors):
    print("❌ Validation failed: \(errors.map(\.message))")
}
```

## Usage

The framework provides two main libraries:

- **ValidatorCore** - Core validation logic and predefined validators. Runs everywhere, including Android.
- **ValidatorUI** - UI integration. The SwiftUI layer runs everywhere; the UIKit/AppKit layer is Apple-only.

### Core Validation

Validate any input with the `Validator` type:

```swift
import ValidatorCore

let validator = Validator()
let result = validator.validate(
    input: "password123",
    rule: LengthValidationRule(
        min: 8,
        error: "Password must be at least 8 characters"
    )
)
```

### UIKit Integration

Import `ValidatorUI` to add validation to UIKit components. This API is available on Apple platforms only —
on Android, use the SwiftUI API below.

```swift
import UIKit
import ValidatorCore
import ValidatorUI

final class LoginViewController: UIViewController {
    private let emailField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()

        emailField.validateOnInputChange(isEnabled: true)
        emailField.add(rule: EmailValidationRule(error: "Please enter a valid email"))

        emailField.validationHandler = { result in
            switch result {
            case .valid:
                print("✅ Valid input")
            case let .invalid(errors):
                print("❌ \(errors.map(\.message).joined(separator: ", "))")
            }
        }
    }
}
```

### SwiftUI Integration

#### Single Field Validation

Use the `.validation()` modifier to observe the result of validating a bound value:

```swift
import SwiftUI
import ValidatorCore
import ValidatorUI

struct LoginView: View {
    @State var email = ""

    var body: some View {
        TextField("Email", text: $email)
            .validation($email, rules: [
                RegexValidationRule(
                    pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}",
                    error: "Invalid email"
                )
            ]) { result in
                if case .invalid(let errors) = result {
                    print("Validation errors: \(errors)")
                }
            }
    }
}
```

Or use `.validate()` to render a custom error view directly beneath the field. The result is derived from the bound
value as the body is evaluated, so the errors shown are always in sync with what the user typed:

```swift
struct LoginView: View {
    @State var password = ""

    var body: some View {
        SecureField("Password", text: $password)
            .validate(item: $password, rules: [
                LengthValidationRule(min: 8, error: "Too short")
            ]) { errors in
                ForEach(errors, id: \.message) { error in
                    Text(error.message)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
    }
}
```

### Form Validation

Manage multiple fields with `FormFieldManager`. Each `@FormField` owns a validation container that re-validates its
value — after an optional debounce interval — and publishes the outcome as observable state:

```swift
import SwiftUI
import ValidatorCore
import ValidatorUI

@MainActor
final class RegistrationForm {
    let manager = FormFieldManager()

    @FormField(rules: [
        LengthValidationRule(min: 2, max: 50, error: "Invalid name length")
    ])
    var firstName = ""

    @FormField(rules: [
        LengthValidationRule(min: 2, max: 50, error: "Invalid name length")
    ])
    var lastName = ""

    @FormField(rules: [
        RegexValidationRule(
            pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}",
            error: "Invalid email"
        )
    ], debounce: 0.3)
    var email = ""

    lazy var firstNameContainer = _firstName.validate(manager: manager)
    lazy var lastNameContainer = _lastName.validate(manager: manager)
    lazy var emailContainer = _email.validate(manager: manager)
}

struct RegistrationView: View {
    @State var form = RegistrationForm()

    var body: some View {
        Form {
            Section("Personal Information") {
                TextField("First Name", text: $form.firstName)
                    .validate(validationContainer: form.firstNameContainer) { errors in
                        ErrorView(errors: errors)
                    }

                TextField("Last Name", text: $form.lastName)
                    .validate(validationContainer: form.lastNameContainer) { errors in
                        ErrorView(errors: errors)
                    }
            }

            Section("Contact") {
                TextField("Email", text: $form.email)
                    .validate(validationContainer: form.emailContainer) { errors in
                        ErrorView(errors: errors)
                    }
            }

            Section {
                Button("Submit") { submitForm() }
                    .disabled(!form.manager.isValid)
            }
        }
    }

    private func submitForm() {
        form.manager.validate()
        print("✅ Form is valid, submitting...")
    }
}
```

`FormFieldManager.isValid` is observable, so reading it in a view body is all that is needed to keep a submit button
enabled or disabled. Call `manager.validate()` to force a re-check of every registered field.

Two things to note when writing this in a Skip target:

- Do **not** mark the form class `@Observable`. `@FormField` is a property wrapper, and the `@Observable` macro
  collides with the storage it synthesises. The validation containers and `FormFieldManager` are already observable,
  which is what refreshes the UI.
- Declare `@State` properties as internal (`@State var`), not `private`. Skip's bridge generator rejects private
  state with *"Private state property cannot be bridged to Android"*.

## Built-in Validators

| Validator | Description | Example |
|-----------|-------------|---------|
| `LengthValidationRule` | Validates string length (min/max) | `LengthValidationRule(min: 3, max: 20, error: "Length must be 3-20 characters")` |
| `NonEmptyValidationRule` | Ensures string is not empty or blank | `NonEmptyValidationRule(error: "Field is required")` |
| `PrefixValidationRule` | Validates string prefix | `PrefixValidationRule(prefix: "https://", error: "URL must start with https://")` |
| `SuffixValidationRule` | Validates string suffix | `SuffixValidationRule(suffix: ".com", error: "Domain must end with .com")` |
| `RegexValidationRule` | Pattern matching validation | `RegexValidationRule(pattern: "^\\d{3}-\\d{4}$", error: "Invalid phone format")` |
| `URLValidationRule` | Validates URL format | `URLValidationRule(error: "Please enter a valid URL")` |
| `CreditCardValidationRule` | Validates credit card numbers (Luhn algorithm) | `CreditCardValidationRule(error: "Invalid card number")` |
| `EmailValidationRule` | Validates email format | `EmailValidationRule(error: "Please enter a valid email")` |
| `CharactersValidationRule` | Validates that a string contains only characters from the allowed CharacterSet | `CharactersValidationRule(characterSet: .letters, error: "Invalid characters")` |
| `NilValidationRule` | Validates that value is nil | `NilValidationRule(error: "Value must be nil")` |
| `PositiveNumberValidationRule` | Validates that value is positive | `PositiveNumberValidationRule(error: "Value must be positive")` |
| `NoWhitespaceValidationRule` | Validates that a string does not contain any whitespace characters | `NoWhitespaceValidationRule(error: "Spaces are not allowed")` |
| `ContainsValidationRule` | Validates that a string contains a specific substring | `ContainsValidationRule(substring: "@", error: "Must contain @")` |
| `EqualityValidationRule`| Validates that the input is equal to a given reference value | `EqualityValidationRule(compareTo: password, error: "Passwords do not match")` |
| `ComparisonValidationRule` | Validates that input against a comparison constraint | `ComparisonValidationRule(greaterThan: 0, error: "Must be greater than 0")` |
| `IBANValidationRule` | Validates that a string is a valid IBAN (International Bank Account Number) | `IBANValidationRule(error: "Invalid IBAN")` |
| `IPAddressValidationRule` | Validates that a string is a valid IPv4 or IPv6 address | `IPAddressValidationRule(version: .v4, error: "Invalid IPv4")` |
| `PostalCodeValidationRule` | Validates postal/ZIP codes for different countries | `PostalCodeValidationRule(country: .uk, error: "Invalid post code")` |
| `Base64ValidationRule` | Validates that a string represents valid Base64-encoded data | `Base64ValidationRule(error: "The input is not valid Base64.")` |
| `UUIDValidationRule` | Validates UUID format | `UUIDValidationRule(error: "Please enter a valid UUID")` |
| `JSONValidationRule` | Validates that a string represents valid JSON | `JSONValidationRule(error: "Invalid JSON")` |

Every rule in this table is available on Android as well as on Apple platforms.

## Custom Validators

Create custom validation rules by conforming to `IValidationRule`:

```swift
import ValidatorCore

struct EmailDomainValidationRule: IValidationRule {
    typealias Input = String

    let allowedDomains: [String]
    let error: IValidationError

    init(allowedDomains: [String], error: IValidationError) {
        self.allowedDomains = allowedDomains
        self.error = error
    }

    func validate(input: String) -> Bool {
        guard let domain = input.split(separator: "@").last else {
            return false
        }
        return allowedDomains.contains(String(domain))
    }
}

// Usage
let rule = EmailDomainValidationRule(
    allowedDomains: ["company.com", "company.org"],
    error: "Only company email addresses are allowed"
)
```

Keep custom rules free of platform-specific API if you intend to run them on Android — plain Swift and Foundation
are portable, while the Objective-C runtime and Combine are not.

### Composing Validators

Combine multiple validators for complex validation logic:

```swift
// Define reusable validation rules
let lengthRule = LengthValidationRule(
    min: 8,
    max: 128,
    error: "Password must be 8-128 characters"
)

let uppercaseRule = RegexValidationRule(
    pattern: ".*[A-Z].*",
    error: "Must contain uppercase letter"
)

let lowercaseRule = RegexValidationRule(
    pattern: ".*[a-z].*",
    error: "Must contain lowercase letter"
)

let numberRule = RegexValidationRule(
    pattern: ".*[0-9].*",
    error: "Must contain number"
)

let specialCharRule = RegexValidationRule(
    pattern: ".*[!@#$%^&*(),.?\":{}|<>].*",
    error: "Must contain special character"
)

// SwiftUI: render every failed rule beneath the field
SecureField("Password", text: $password)
    .validate(item: $password, rules: [
        lengthRule,
        uppercaseRule,
        lowercaseRule,
        numberRule,
        specialCharRule
    ]) { errors in
        ForEach(errors, id: \.message) { error in
            Text(error.message)
                .foregroundColor(.red)
                .font(.caption)
        }
    }

// UIKit (Apple platforms): pass the same rules to your text field
passwordField.validate(rules: [
    lengthRule,
    uppercaseRule,
    lowercaseRule,
    numberRule,
    specialCharRule
])
```

## Examples

You can find usage examples in the [Examples](./Examples/) directory of the repository.

These examples demonstrate how to integrate the package, configure validation rules,
and build real-world user interfaces using `ValidatorCore` and `ValidatorUI`.

## Communication

- 🐛 **Found a bug?** [Open an issue](https://github.com/Clockworks-Solutions/validator/issues/new)
- 💡 **Have a feature request?** [Open an issue](https://github.com/Clockworks-Solutions/validator/issues/new)
- ❓ **Questions?** [Start a discussion](https://github.com/Clockworks-Solutions/validator/discussions)
- 🔒 **Security issue?** Email dhruv@clockworks.co.in

## Contributing

Contributions are welcome. Please read our [Contributing Guide](CONTRIBUTING.md) to learn about the development
process, how to propose bugfixes and improvements, and how to build and test your changes.

### Development Setup

Bootstrap the development environment:

```bash
mise install
```

Install the Skip toolchain, which the build requires on every platform:

```bash
brew install skiptools/skip/skip
```

### Code of Conduct

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## License

Validator is released under the MIT license. See [LICENSE](LICENSE) for details.

Original work © Nikita Vasilev ([space-code](https://github.com/space-code)); fork maintained by Clockworks Solutions.


