import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// MARK: - SingletonMacro

/// A macro that generates a singleton instance for a struct or class.
///
/// This macro adds a `static let shared` property that acts as the singleton instance.

/// Implementation of the `@singleton` macro.
public struct SingletonMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard var classDeclaration = declaration.as(ClassDeclSyntax.self) else {
            throw SingletonMacroError.mustBeClass
        }

        let className = classDeclaration.name.text

//        let staticLetShared = MemberBlockItemSyntax(decl: DeclSyntax(
//            """
//                @MainActor public static let shared = \(raw: className)()
//            """
//        ))
//
//        // Add private init to prevent external instantiation.
//        // We only add a private init if no other initializers are defined.
//        if classDeclaration.memberBlock.members.compactMap({ $0.decl.as(InitializerDeclSyntax.self) }).isEmpty {
//            let initDecl = MemberBlockItemSyntax(decl: DeclSyntax(
//                """
//                private init() {}
//                """
//            ))
//            classDeclaration.memberBlock.members.append(contentsOf: [staticLetShared, initDecl])
//
//        } else {
//            classDeclaration.memberBlock.members.append(staticLetShared)
//        }
//
//        return [DeclSyntax(classDeclaration)]

        // Create the "public static let shared" part
        let publicKeyword = TokenSyntax.keyword(.public)
        let staticKeyword = TokenSyntax.keyword(.static)
        let letKeyword = TokenSyntax.keyword(.let)
        let sharedIdentifier = TokenSyntax.identifier("shared")
        let equalToken = TokenSyntax.equalToken()

        // Create the "@MainActor" attribute
        let mainActorAttribute = AttributeSyntax(
            atSign: .atSignToken(),
            attributeName: IdentifierTypeSyntax(name: .identifier("MainActor"))
        )

        let attributes = AttributeListSyntax([AttributeListSyntax.Element(mainActorAttribute)])

        // Create the "ClassName()" part

        let functionCallExpr = FunctionCallExprSyntax(
            calledExpression: DeclReferenceExprSyntax(baseName: .identifier(className)),
            leftParen: .leftParenToken(),
            arguments: [], // Provide an empty argument list
            rightParen: .rightParenToken()
        )

        // Combine everything into a variable declaration
        let variableDecl = VariableDeclSyntax(
            attributes: attributes, // Add the attribute list here
            modifiers: DeclModifierListSyntax([
                DeclModifierSyntax(name: publicKeyword),
                DeclModifierSyntax(name: staticKeyword)
            ]),
            bindingSpecifier: letKeyword,
            bindings: PatternBindingListSyntax([
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: sharedIdentifier),
                    typeAnnotation: nil,
                    initializer: InitializerClauseSyntax(
                        equal: equalToken,
                        value: functionCallExpr
                    ),
                    accessorBlock: nil
                )
            ])
        )

        let sharedVariable = MemberBlockItemSyntax(decl: variableDecl)
        classDeclaration.memberBlock.members.append(sharedVariable)

        return [DeclSyntax(classDeclaration)]
    }
}

// MARK: SingletonMacro.SingletonMacroError

extension SingletonMacro {
    enum SingletonMacroError: Error, CustomStringConvertible {
        case mustBeClass
        case haveMoreThanOneArgument
        case mustBeIntegerValue(argument: ExprSyntax)

        var description: String {
            switch self {
            case .mustBeClass:
                return "`@Singleton` can only be applied to classes"
            case .haveMoreThanOneArgument:
                return "The `#DoubleValue()` macro supports only one argument. Please provide a single integer value."
            case let .mustBeIntegerValue(argument):
                return "The argument provided to `#DoubleValue()` must be an integer literal. Found: \(argument)"
            }
        }
    }
}
