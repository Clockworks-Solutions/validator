//
// Validator
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import ValidatorCore

// MARK: - FormField

/// A property wrapper representing a single field in a form.
///
/// Encapsulates a value, its validation rules, and the validator used for checking the value.
/// Provides automatic integration with a form via the `IFormField` protocol.
///
/// # Example:
/// ```swift
/// @FormField(rules: [NonEmptyValidationRule(error: "Required")], debounce: 0.3)
/// var email: String = ""
/// ```
@MainActor
@propertyWrapper
public final class FormField<Value>: IFormField {
    // MARK: Properties

    /// The container that stores the value and tracks its validation state.
    public let container: FormValidationContainter<Value>

    /// The wrapped property value.
    public var wrappedValue: Value {
        get { container.value }
        set { container.value = newValue }
    }

    /// The validation container backing this field, so callers can read its validation result.
    public var projectedValue: any IFormValidationContainer<Value> {
        container
    }

    // MARK: Initialization

    /// Creates a new `FormField` with a value, validator, and rules.
    ///
    /// - Parameters:
    ///   - wrappedValue: The initial value of the field.
    ///   - validator: The validator instance to use (defaults to `Validator()`).
    ///   - rules: The array of validation rules to apply to the value.
    ///   - debounce: The time to wait after a change before the new value is validated.
    public init(
        wrappedValue: Value,
        validator: IValidator = Validator(),
        rules: [any IValidationRule<Value>],
        debounce: TimeInterval = .zero
    ) {
        container = FormValidationContainter(
            value: wrappedValue,
            validator: validator,
            rules: rules,
            debounce: debounce
        )
    }

    // MARK: IFormField

    /// Validates the field using its rules and connects it to a form manager.
    ///
    /// - Parameter manager: The form field manager that tracks this field.
    ///
    /// - Returns: A `IFormValidationContainer` which exposes the field's validation result.
    @discardableResult
    @inlinable @inline(always) public func validate(manager: some IFormFieldManager) -> any IFormValidationContainer {
        manager.append(validator: container)
        return container
    }
}
