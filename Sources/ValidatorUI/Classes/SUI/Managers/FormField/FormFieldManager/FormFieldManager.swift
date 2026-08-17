//
// Validator
// Copyright © 2023 Space Code. All rights reserved.
//

// SkipFuse must be imported for `@Observable` to bind to Skip's bridged `Observation.ObservationRegistrar`, which forwards property reads and writes into Compose on Android.
import Foundation
import Observation
import SkipFuse

// MARK: - FormFieldManager

/// A concrete implementation of `IFormFieldManager` that manages the validation state of a form.
///
/// Tracks all registered form fields, observes their validation results,
/// and exposes a single `isValid` property that represents the overall form validity.
@MainActor
@Observable
public final class FormFieldManager: IFormFieldManager {
    // MARK: Properties

    /// A Boolean value indicating whether all registered fields are valid.
    ///
    /// Observable, so SwiftUI views update automatically as the form's validity changes.
    public private(set) var isValid = false

    /// The collection of validation containers for all registered form fields.
    @ObservationIgnored private var validators: [any IFormValidationContainer] = []

    // MARK: Initialization

    /// Creates a new instance of `FormFieldManager`.
    public init() {}

    // MARK: IFormFieldManager

    /// Appends a new field validator to the manager.
    ///
    /// - Parameter validator: The validation container for a specific field.
    ///
    /// The manager observes the validator's result so that any change automatically triggers
    /// re-evaluation of the form's overall validity.
    public func append(validator: some IFormValidationContainer) {
        validators.append(validator)

        validate()
        observeValidators()
    }

    /// Recalculates the overall form validity by checking all registered validators.
    public func validate() {
        isValid = !validators
            .contains(where: { $0.validate() != .valid })
    }

    // MARK: Private

    /// Recomputes `isValid` whenever any registered field publishes a new validation result.
    ///
    /// All containers are tracked by a single registration, which is re-armed after each
    /// notification because `withObservationTracking` reports only one change per registration.
    private func observeValidators() {
        withObservationTracking {
            for validator in validators {
                _ = validator.validationResult
            }
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.validate()
                self?.observeValidators()
            }
        }
    }
}
