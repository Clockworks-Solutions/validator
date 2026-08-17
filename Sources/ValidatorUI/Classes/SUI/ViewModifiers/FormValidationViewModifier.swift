//
// Validator
// Copyright © 2023 Space Code. All rights reserved.
//

// SkipFuseUI re-exports SwiftUI on Apple platforms and SkipSwiftUI on Android.
import SkipFuseUI
import ValidatorCore

/// A SwiftUI `ViewModifier` that displays validation messages for a form.
///
/// This modifier reads the observable validation result of a `validationContainer`, so the UI
/// updates automatically whenever that result changes. It displays a custom error view for
/// invalid input.
///
/// - Parameter ErrorView: The type of view used to display validation errors.
public struct FormValidationViewModifier<ErrorView: View>: ViewModifier {
    // MARK: Properties

    /// A container that holds form validation logic and exposes validation results.
    private let validationContainer: any IFormValidationContainer

    /// A closure that constructs a SwiftUI view from a list of validation errors.
    @ViewBuilder private let content: ([any IValidationError]) -> ErrorView

    // MARK: Initialization

    /// Initializes the modifier with a validation container and a custom error view builder.
    ///
    /// - Parameters:
    ///   - validationContainer: The container holding the validation logic for the form.
    ///   - content: A closure that takes an array of errors and returns a view to display them.
    public init(
        validationContainer: any IFormValidationContainer,
        @ViewBuilder content: @escaping ([any IValidationError]) -> ErrorView
    ) {
        self.validationContainer = validationContainer
        self.content = content
    }

    // MARK: ViewModifier

    /// Modifies the view to include validation error messages below the content.
    ///
    /// - Parameter content: The original view content.
    /// - Returns: A view containing the original content and validation messages.
    public func body(content: Content) -> some View {
        VStack(alignment: .leading) {
            content
            validationMessageView
        }
    }


    // Skip's bridge generator emits an unlabelled `value.body($0)` for generic `ViewModifier`s, which
    // matches neither SwiftUI's nor SkipUI's `body(content:)`. This overload gives it a target.
    public func body(_ content: Content) -> some View {
        body(content: content)
    }

    // MARK: Private

    /// Reading the container's observable `validationResult` here is what subscribes this view to
    /// updates, on both Apple platforms and Android.
    private var validationMessageView: some View {
        switch validationContainer.validationResult {
        case .valid:
            EmptyView().eraseToAnyView()
        case let .invalid(errors):
            content(errors).eraseToAnyView()
        }
    }
}
