//
// Validator
// Copyright © 2025 Space Code. All rights reserved.
//

import Foundation

/// Validates that a string contains only allowed characters.
///
/// # Example:
/// ```swift
/// let rule = CharactersValidationRule(characterSet: .letters, error: "Only letters allowed")
/// rule.validate(input: "Hello") // true
/// rule.validate(input: "Hello123") // false
/// ```
public struct CharactersValidationRule: IValidationRule {
    // MARK: Types

    public typealias Input = String

    // MARK: Properties

    /// The set of allowed characters.
    public let characterSet: CharacterSet

    /// The validation error returned if input contains invalid characters.
    public let error: IValidationError

    // MARK: Initialization

    /// Initializes a characters validation rule.
    ///
    /// - Parameters:
    ///   - characterSet: Allowed character set.
    ///   - error: The validation error to return if input fails validation.
    public init(characterSet: CharacterSet, error: IValidationError) {
        self.characterSet = characterSet
        self.error = error
    }

    // MARK: IValidationRule

    public func validate(input: String) -> Bool {
        input.rangeOfCharacter(from: characterSet.inverted) == .none
    }
}

// MARK: - IValidationRule: CharactersValidationRule

public extension IValidationRule where Self == CharactersValidationRule {
    @inlinable @inline(always) static func character(set: CharacterSet, error: IValidationError) -> Self {
        .init(characterSet: set, error: error)
    }
}
