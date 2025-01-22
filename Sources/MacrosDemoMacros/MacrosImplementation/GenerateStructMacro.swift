import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// MARK: - StructGeneratorMacro

/// A macro to generate a Swift struct with specified properties.
///
/// This macro validates input arguments, ensures the struct name starts with an uppercase letter,
/// and dynamically creates the struct and its properties.
///
/// - Parameters:
///   - node: The macro expansion syntax containing the struct name and fields.
///   - context: The macro expansion context.

public struct StructGeneratorMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard node.arguments.count == 2,
              let structName = node.arguments.first?.expression.stringLiteralValue(),
              let fieldsExpr = node.arguments.last?.expression.as(DictionaryExprSyntax.self)
        else {
            throw StructGeneratorMacroError.invalidArguments
        }

        // Rule: Struct names must start with an uppercase letter
        guard structName.first?.isUppercase == true else {
            throw StructGeneratorMacroError.invalidClassName
        }

        var memberDecls: [DeclSyntax] = []
        let elements = fieldsExpr.content.as(DictionaryElementListSyntax.self)

        memberDecls = elements?.compactMap { element -> DeclSyntax? in
            guard let propertyName = element.key.stringLiteralValue(),
                  let propertyType = element.value.stringLiteralValue()
            else { return nil }

            return DeclSyntax(VariableDeclSyntax.createVariableDeclaration(
                name: propertyName,
                type: propertyType
            ))

        } ?? []

        guard memberDecls.isEmpty == false else {
            throw StructGeneratorMacroError.failedToGenerateArguments
        }

        let structDecl = StructDeclSyntax.createStructDeclaration(
            name: structName,
            members: memberDecls
        )
        return [DeclSyntax(structDecl)]
    }
}

// MARK: StructGeneratorMacro.StructGeneratorMacroError

extension StructGeneratorMacro {
    enum StructGeneratorMacroError: Error {
        case invalidArguments
        case invalidClassName
        case failedToGenerateArguments
    }
}
