import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// MARK: - TypeCategory

// Enhanced type system with custom type support
public indirect enum TypeCategory {
    case primitive(PrimitiveType)
    case custom(String)
    case optional(TypeCategory)
    case array(TypeCategory)
    case dictionary(key: TypeCategory, value: TypeCategory)

    var description: String {
        switch self {
        case let .primitive(type):
            return type.rawValue
        case let .custom(name):
            return name
        case let .optional(wrapped):
            return "\(wrapped.description)?"
        case let .array(element):
            return "[\(element.description)]"
        case let .dictionary(key, value):
            return "[\(key.description): \(value.description)]"
        }
    }
}

// MARK: - PrimitiveType

public enum PrimitiveType: String, CaseIterable {
    case string = "String"
    case int = "Int"
    case double = "Double"
    case bool = "Bool"
    case float = "Float"
    case uuid = "UUID"
    case date = "Date"
}

// MARK: - StructMacroError

enum StructMacroError: Error, CustomStringConvertible {
    case invalidStructName
    case invalidFieldName(String)
    case invalidTypeFormat(String)
    case emptyFields

    var description: String {
        switch self {
        case .invalidStructName:
            return "Struct name must be a valid Swift identifier"
        case let .invalidFieldName(name):
            return "Invalid field name: \(name)"
        case let .invalidTypeFormat(type):
            return "Invalid type format: \(type)"
        case .emptyFields:
            return "Struct must have at least one field"
        }
    }
}

// MARK: - StructGeneratorMacro

//// MARK: - StructGeneratorMacro
//
// public struct StructGeneratorMacro: DeclarationMacro {
//    public static func expansion(
//        of node: some FreestandingMacroExpansionSyntax,
//        in context: some MacroExpansionContext
//    ) throws -> [DeclSyntax] {
//        let argument = node.arguments
//        guard argument.count == 2 else {
//            throw StructMacroError.invalidStructName
//        }
//
//        guard let structNameExpr = argument.first?.expression.as(StringLiteralExprSyntax.self),
//              let structName = structNameExpr.segments.first?.description,
//              isValidSwiftIdentifier(structName) else {
//            throw StructMacroError.invalidStructName
//        }
//
//        // Get dictionary expression and elements
//        guard let fieldsExpr = argument.last?.expression.as(DictionaryExprSyntax.self),
//              let elementList = fieldsExpr.content.as(DictionaryElementListSyntax.self),
//              !elementList.isEmpty else {
//            throw StructMacroError.emptyFields
//        }
//
//        var properties: [String] = []
//        var decoderStatements: [String] = []
//
//        // Process each dictionary element
//        for element in elementList {
//            guard let key = element.key.as(StringLiteralExprSyntax.self)?.segments.first?.description,
//                  isValidSwiftIdentifier(key) else {
//                throw StructMacroError.invalidFieldName(element.key.description)
//            }
//
//            guard let valueExpr = element.value.as(StringLiteralExprSyntax.self),
//                  let typeStr = valueExpr.segments.first?.description else {
//                throw StructMacroError.invalidTypeFormat(element.value.description)
//            }
//
//            let type = try parseType(typeStr)
//            properties.append("    public var \(key): \(type.description)")
//            decoderStatements.append(generateDecoderStatement(key: key, type: type))
//        }
//
//        let structDecl = """
//        public struct \(structName): Codable, Hashable {
//        \(properties.joined(separator: "\n"))
//
//            public init() {}
//
//            public init(from decoder: Decoder) throws {
//                let container = try decoder.container(keyedBy: CodingKeys.self)
//        \(decoderStatements.joined(separator: "\n"))
//            }
//        }
//        """
//
//        return [DeclSyntax(stringLiteral: structDecl)]
//    }
//
//    private static func parseType(_ typeStr: String) throws -> TypeCategory {
//        // Handle arrays
//        if typeStr.hasPrefix("[") && typeStr.hasSuffix("]") {
//            if typeStr.contains(":") {
//                // Dictionary type
//                let inner = String(typeStr.dropFirst().dropLast())
//                let parts = inner.split(separator: ":")
//                guard parts.count == 2 else {
//                    throw StructMacroError.invalidTypeFormat(typeStr)
//                }
//                let keyType = try parseType(String(parts[0].trimmingCharacters(in: .whitespaces)))
//                let valueType = try parseType(String(parts[1].trimmingCharacters(in: .whitespaces)))
//                return .dictionary(key: keyType, value: valueType)
//            } else {
//                // Array type
//                let elementType = try parseType(String(typeStr.dropFirst().dropLast()))
//                return .array(elementType)
//            }
//        }
//
//        // Handle optionals
//        if typeStr.hasSuffix("?") {
//            let baseType = try parseType(String(typeStr.dropLast()))
//            return .optional(baseType)
//        }
//
//        // Handle primitive and custom types
//        if let primitiveType = PrimitiveType(rawValue: typeStr) {
//            return .primitive(primitiveType)
//        }
//
//        // Validate custom type name
//        if isValidSwiftIdentifier(typeStr) {
//            return .custom(typeStr)
//        }
//
//        throw StructMacroError.invalidTypeFormat(typeStr)
//    }
//
//    private static func generateDecoderStatement(key: String, type: TypeCategory) -> String {
//        switch type {
//        case let .optional(wrapped):
//            return "        self.\(key) = try container.decodeIfPresent(\(wrapped.description).self, forKey: .\(key))"
//        default:
//            return "        self.\(key) = try container.decode(\(type.description).self, forKey: .\(key))"
//        }
//    }
//
//    private static func isValidSwiftIdentifier(_ str: String) -> Bool {
//        let pattern = "^[a-zA-Z_][a-zA-Z0-9_]*$"
//        return str.range(of: pattern, options: .regularExpression) != nil
//    }
// }

import SwiftSyntax
import SwiftSyntaxMacros

// MARK: - StructGeneratorMacro

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
            throw StructGeneratorMacroError.invalidArguments
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
    }
}
