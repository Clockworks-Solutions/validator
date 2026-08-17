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

/// A concrete implementation of `IFormValidationContainer` for a single form field.
///
/// Holds the field's value, its validator and its rules, and re-validates the value whenever it
/// changes. Results are delivered through the observable `validationResult` property.
///
/// Value changes are coalesced by `debounce` seconds: each change cancels the pending validation
/// and starts a new one, so only the last value in a burst of edits is validated.
@MainActor
@Observable
public final class FormValidationContainter<Value>: IFormValidationContainer {
    // MARK: Properties

    /// The current value of the form field.
    public var value: Value

    /// The most recent validation result.
    ///
    /// Starts out `.valid` and is updated once the value changes, so a freshly built form does not
    /// show errors before the user has typed anything.
    public private(set) var validationResult: ValidationResult = .valid

    /// The validator used to check the field's value against its rules.
    @ObservationIgnored public let validator: IValidator

    /// The validation rules applied to the field.
    @ObservationIgnored public let rules: [any IValidationRule<Value>]

    /// The time to wait after a change before the new value is validated.
    @ObservationIgnored public let debounce: TimeInterval

    /// The in-flight debounced validation, cancelled whenever a newer value arrives.
    @ObservationIgnored private var validationTask: Task<Void, Never>?

    // MARK: Initialization

    /// Creates a new form validation container.
    ///
    /// - Parameters:
    ///   - value: The initial value of the field.
    ///   - validator: The validator instance used to apply rules.
    ///   - rules: The validation rules to apply.
    ///   - debounce: The time to wait after a change before validating. Defaults to no delay.
    public init(
        value: Value,
        validator: IValidator = Validator(),
        rules: [any IValidationRule<Value>],
        debounce: TimeInterval = .zero
    ) {
        self.value = value
        self.validator = validator
        self.rules = rules
        self.debounce = debounce

        observeValue()
    }

    // MARK: IFormValidationContainer

    /// Validates the current value using the associated rules and validator.
    ///
    /// - Returns: The `ValidationResult` of the validation.
    public func validate() -> ValidationResult {
        validator.validate(input: value, rules: rules)
    }

    // MARK: Private

    /// Re-validates the value whenever it changes.
    ///
    /// `withObservationTracking` reports a single change, so the observation is re-armed after every
    /// notification. The callback is delivered before the new value is stored, hence the hop onto a
    /// task, which also guarantees validation runs against the value the user actually ended up with.
    private func observeValue() {
        withObservationTracking {
            _ = value
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.scheduleValidation()
                self?.observeValue()
            }
        }
    }

    /// Schedules validation of the current value, cancelling any validation that has not run yet.
    private func scheduleValidation() {
        validationTask?.cancel()
        validationTask = Task { [weak self] in
            guard let self else { return }

            if debounce > .zero {
                try? await Task.sleep(for: .seconds(debounce))
            }

            guard !Task.isCancelled else { return }

            validationResult = validate()
        }
    }
}
