import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacrosDemoPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DoubleValueMacro.self,
        StructGeneratorMacro.self
    ]
}
