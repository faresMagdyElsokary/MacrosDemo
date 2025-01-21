import SwiftSyntax
import SwiftSyntaxBuilder

extension StructDeclSyntax {
    static func createStructDeclaration(
        name: String,
        members: [DeclSyntax] = [],
        modifiers: [DeclModifierSyntax] = []
    ) -> StructDeclSyntax {
        let identifier = TokenSyntax.identifier(name)

        let memberBlockItemList = MemberBlockItemListSyntax(members.map { MemberBlockItemSyntax(decl: $0) })

        return  StructDeclSyntax(
            modifiers: DeclModifierListSyntax(modifiers),
            name: identifier,
            memberBlock: MemberBlockSyntax(
                leftBrace: .leftBraceToken(),
                members: memberBlockItemList,
                rightBrace: .rightBraceToken()
            )
        )
    }
}
