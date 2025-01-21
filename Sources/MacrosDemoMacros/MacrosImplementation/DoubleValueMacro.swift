import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// MARK: - DoubleValueMacro

/// This macro converts an integer literal to a Double value.
///
/// Usage:
///
/// ```swift
/// let myDouble = #doubleValue(10)
/// ```
///
/// This macro will expand to:
///
/// ```swift
/// let myDouble = Double(10)
/// ```
///
/// **Arguments:**
///
/// - Requires exactly one argument.
/// - The argument must be an integer literal.
///
/// **Throws:**
///
/// - `DoubleValueMacroError.haveNoArguments`: If no arguments are provided.
/// - `DoubleValueMacroError.haveMoreThanOneArgument`: If more than one argument is provided.
/// - `DoubleValueMacroError.mustBeIntegerValue`: If the argument is not an integer literal.
public struct DoubleValueMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard node.arguments.count == 1 else {
            throw DoubleValueMacroError.haveMoreThanOneArgument
        }
        guard let argument = node.arguments.first?.expression else {
            throw DoubleValueMacroError.haveNoArguments
        }

        guard argument.isIntegerLiteral(),
              let integerLiteral = argument.integerLiteralValue() else {
            throw DoubleValueMacroError.mustBeIntegerValue(argument: argument)
        }

        return "Double(\(raw: integerLiteral))"
    }
}

// MARK: DoubleValueMacro.DoubleValueMacroError

extension DoubleValueMacro {
    enum DoubleValueMacroError: Error, CustomStringConvertible {
        case haveNoArguments
        case haveMoreThanOneArgument
        case mustBeIntegerValue(argument: ExprSyntax)

        var description: String {
            switch self {
            case .haveNoArguments:
                return "The `#DoubleValue()` macro requires exactly one argument."
            case .haveMoreThanOneArgument:
                return "The `#DoubleValue()` macro supports only one argument. Please provide a single integer value."
            case let .mustBeIntegerValue(argument):
                return "The argument provided to `#DoubleValue()` must be an integer literal. Found: \(argument)"
            }
        }
    }
}
