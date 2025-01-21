//
//  VariableDeclSyntax+.swift
//  MacrosDemo
//
//  Created by fares on 21/01/2025.
//

import SwiftSyntax
import SwiftSyntaxBuilder

extension VariableDeclSyntax {
    static func createVariableDeclaration(
        name: String,
        type: String? = nil,
        initializer: ExprSyntax? = nil,
        isConstant: Bool = false,
        modifiers: [DeclModifierSyntax] = []
    ) -> VariableDeclSyntax {
        let identifier = PatternSyntax(IdentifierPatternSyntax(identifier: .identifier(name)))

        let typeAnnotation: TypeAnnotationSyntax? = type.map {
            TypeAnnotationSyntax(colon: .colonToken(), type: TypeSyntax(IdentifierTypeSyntax(name: .identifier($0))))
        }

        let initializerClause: InitializerClauseSyntax? = initializer.map {
            InitializerClauseSyntax(equal: .equalToken(), value: $0)
        }

        let binding: PatternBindingSyntax = PatternBindingSyntax(
            pattern: identifier,
            typeAnnotation: typeAnnotation,
            initializer: initializerClause
        )

        let keyword: TokenSyntax = isConstant ? .keyword(.let) : .keyword(.var)

        return VariableDeclSyntax(
            modifiers: modifiers.isEmpty ? [] : DeclModifierListSyntax(modifiers),
            bindingSpecifier: keyword,
            bindings: PatternBindingListSyntax([binding])
        )
    }
}
