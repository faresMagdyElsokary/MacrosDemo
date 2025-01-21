import SwiftSyntax
import SwiftSyntaxBuilder

extension ExprSyntax {
    func stringLiteralValue() -> String? {
        guard let stringLiteral = self.as(StringLiteralExprSyntax.self) else {
            return nil
        }

        var result = ""
        for segment in stringLiteral.segments {
            switch segment {
            case let .stringSegment(stringSegment):
                result += stringSegment.content.text
            case let .expressionSegment(expressionSegment):
                if let interpolatedValue = interpolatedStringValue(from: expressionSegment) { // Call the helper function
                    result += interpolatedValue
                } else {
                    return nil
                }
            }
        }
        return result
    }
}

private func interpolatedStringValue(from expressionSegment: ExpressionSegmentSyntax) -> String? {
    // Correct way to access the expression:
    let expression = expressionSegment.expressions
    guard let identifierExpr = expression.as(DeclReferenceExprSyntax.self) else {
        // Handle other expression types (function calls, member access, etc.) as needed.
        return nil
    }
    return identifierExpr.baseName.text
}
