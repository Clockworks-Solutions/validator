//
// Validator
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
// SkipFuse must be imported for `@Observable` to bind to Skip's bridged `Observation.ObservationRegistrar`,
// which forwards property reads and writes into Compose on Android.
import Observation
import SkipFuse
import ValidatorCore

// MARK: - IFormValidationContainer

/// A container that encapsulates validation logic for a single form field.
///
/// The container owns the field's current value, re-validates whenever that value changes, and
/// exposes the outcome through the observable `validationResult` property. A SwiftUI view that
/// reads `validationResult` inside its `body` is refreshed automatically when it changes.
///
/// - Note: Built on `Observation` rather than `Combine`, which the Android Swift SDK does not ship,
///         so Apple platforms and Android run the same code.
@MainActor
public protocol IFormValidationContainer<Value>: AnyObject, Observable {
    associatedtype Value

    /// The current value of the form field.
    ///
    /// Assigning a new value schedules re-validation, honouring the container's debounce interval.
    var value: Value { get set }

    /// The most recent validation result.
    ///
    /// This property is observable: reading it from a SwiftUI `body` subscribes the view to updates.
    var validationResult: ValidationResult { get }

    /// The validator used to evaluate the field's value against the provided rules.
    var validator: IValidator { get }

    /// The array of validation rules to apply to the field.
    var rules: [any IValidationRule<Value>] { get }

    /// Performs validation on the current value of the field.
    ///
    /// - Returns: The `ValidationResult` indicating whether the field is valid or contains errors.
    func validate() -> ValidationResult
}
