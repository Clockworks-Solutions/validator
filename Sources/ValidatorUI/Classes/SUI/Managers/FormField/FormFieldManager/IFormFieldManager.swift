//
// Validator
// Copyright © 2023 Space Code. All rights reserved.
//

// SkipFuse must be imported for `@Observable` to bind to Skip's bridged `Observation.ObservationRegistrar`, which forwards property reads and writes into Compose on Android.

import Foundation
import Observation
import SkipFuse

// MARK: - IFormFieldManager

/// A type that manages the validation state of a form.
///
/// The form field manager keeps track of all fields and their validation containers,
/// provides a centralized way to query the overall form validity, and allows UI components
/// to reactively respond to validation changes.
///
/// Conforms to `Observable` so SwiftUI views can observe changes in form validation state.
@MainActor
public protocol IFormFieldManager: AnyObject, Observable {
    /// A Boolean value indicating whether all fields in the form are valid.
    ///
    /// Returns `true` only if every registered field is valid.
    var isValid: Bool { get }

    /// Appends a new validator to the manager.
    ///
    /// - Parameter validator: The validation container that encompasses
    ///                        the required validation logic for a specific field.
    ///
    /// After appending, the manager tracks this validator and includes it
    /// in the computation of `isValid`.
    func append(validator: some IFormValidationContainer)
}
