import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct EnvironmentActionMacro: MemberMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        guard let passedArgType = node.attributeName
            .as(IdentifierTypeSyntax.self)?
            .genericArgumentClause?
            .arguments
            .first
        else {
            return []
        }

        let isVoid = passedArgType.trimmedDescription == "Void"

        // @EnvironmentAction should only be attached to a struct
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw MacroError.notAttachedToStruct
        }

        let structName = structDecl.name.text

        // @EnvironmentAction can only be applied to structs that end with `Action`
        guard structName.hasSuffix("Action") else {
            throw MacroError.invalidNamingConvention
        }

        guard let baseName = structName.split(separator: "Action").first else {
            throw MacroError.invalidNamingConvention
        }
        let callbackName = "on\(baseName)"
        let callbackType = "On\(baseName)"

        let typealiasDecl: DeclSyntax = if isVoid {
            """
            public typealias \(raw: callbackType) = (@MainActor () -> Void)
            """

        } else {
            """
            public typealias \(raw: callbackType) = (@MainActor (\(passedArgType)) -> Void)
            """
        }

        let callAsFunctionDecl: DeclSyntax = if isVoid {
            """
            @MainActor
            public func callAsFunction() {
                self.\(raw: callbackName)()
            }
            """
        } else {
            """
            @MainActor
            public func callAsFunction(_ arg: \(passedArgType)) {
                self.\(raw: callbackName)(arg)
            }
            """
        }

        let defaultDecl: DeclSyntax = if isVoid {
            """
            public static let `default`: \(raw: structName) = .init {
                print("'\(raw:structName)' is not implemented!")
            }
            """
        } else {
            """
            public static let `default`: \(raw: structName) = .init { _ in
                print("'\(raw:structName)' is not implemented!")
            }
            """
        }

        return [
            typealiasDecl,
            """
            private let \(raw: callbackName): \(raw: callbackType)
            """,

            """
            public init( _ \(raw: callbackName): @escaping \(raw: callbackType)) {
                self.\(raw: callbackName) = \(raw: callbackName)
            }
            """,
            callAsFunctionDecl,
            defaultDecl

        ]
    }

}

@main
struct EnvironmentActionPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        EnvironmentActionMacro.self,
    ]
}

enum MacroError: Error, CustomStringConvertible {
    case notAttachedToStruct
    case invalidNamingConvention

    var description: String {
        switch self {
            case .notAttachedToStruct:
                "@EnvironmentAction can only be attached to structs"
            case .invalidNamingConvention:
                "@EnvironmentAction can only be applied to a struct that ends with 'Action'"
        }

    }
}
