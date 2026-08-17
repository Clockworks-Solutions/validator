//
// Validator
// Copyright © 2023 Space Code. All rights reserved.
//

// SkipFuseUI re-exports SwiftUI on Apple platforms and SkipSwiftUI on Android.
import SkipFuseUI
import ValidatorCore

// swiftlint:disable:next prefixed_toplevel_constant
private let validator = Validator()

/// A  validation view modifier.
///
/// The validation view modifier automatically tracks validation errors,
/// uses the content view builder to construct an error view, and displays
/// it to the user.
///
/// ```
/// struct ContentView: View {
///    @State private var text: String = "Text"
///
///    var body: some View {
///        VStack {
///            TextField("Title", text: $text)
///                .modifier(
///                    ValidationViewModifier(
///                        item: $text,
///                        rules: [
///                            LengthValidationRule(max: 10, error: "The error message"),
///                        ],
///                        content: { errors in
///                            Text(errors.map { $0.message }.joined(separator: " "))
///                        }
///                    )
///                )
///            Spacer()
///        }
///        .padding()
///    }
/// }
/// ```
public struct ValidationViewModifier<T, ErrorView: View>: ViewModifier {
    // MARK: Properties

    /// The value to validate, wrapped as a `Binding` so changes are observed automatically.
    @Binding private var item: T

    /// A closure that constructs a SwiftUI view from a list of validation errors.
    @ViewBuilder private let content: ([any IValidationError]) -> ErrorView

    /// The array of validation rules applied to the binding value.
    public let rules: [any IValidationRule<T>]

    /// Creates a new instance of the `ValidationViewModifier`.
    ///
    /// - Parameters:
    ///   - item: The binding value to validate.
    ///   - rules: The array of validation rules to apply.
    ///   - content: A closure that builds a custom error view from the validation errors.
    public init(
        item: Binding<T>,
        rules: [any IValidationRule<T>],
        @ViewBuilder content: @escaping ([any IValidationError]) -> ErrorView
    ) {
        _item = item
        self.rules = rules
        self.content = content
    }

    // MARK: ViewModifier

    /// Modifies the view to include validation logic and error messages below the content.
    ///
    /// - Parameter content: The original view content.
    ///
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

    /// Derived from the bound value as the body is evaluated, so the rendered errors are a pure
    /// function of the input and appear on the same frame on SwiftUI and on Compose.
    private var validationMessageView: some View {
        switch validator.validate(input: item, rules: rules) {
        case .valid:
            EmptyView().eraseToAnyView()
        case let .invalid(errors):
            content(errors).eraseToAnyView()
        }
    }
}
