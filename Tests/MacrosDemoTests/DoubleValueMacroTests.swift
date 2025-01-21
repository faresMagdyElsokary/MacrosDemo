import MacrosDemoMacros
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// MARK: - DoubleValueMacroTests

class DoubleValueMacroTests: XCTestCase {
    let testMacros: [String: Macro.Type] = [
        "doubleValue": DoubleValueMacro.self
    ]

    func testMacro() {
        assertMacroExpansion(
            """
            #doubleValue(10)
            """,
            expandedSource: """
            Double(10)
            """,
            macros: testMacros
        )
    }
}
