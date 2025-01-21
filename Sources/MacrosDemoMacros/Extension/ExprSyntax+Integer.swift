import SwiftSyntax

public extension ExprSyntax {
    /// Checks if the syntax node is an integer literal.
    func isIntegerLiteral() -> Bool {
        return self.as(IntegerLiteralExprSyntax.self) != nil
    }

    /// Extracts the integer value if the syntax node is an integer literal.
    func integerLiteralValue() -> Int? {
        guard let integerLiteral = self.as(IntegerLiteralExprSyntax.self) else {
            return nil
        }

        // Extract the literal text from the token
        let literalText = integerLiteral.literal.text

        // Convert the literal text (which is a String) into an integer
        return Int(literalText)
    }
}
