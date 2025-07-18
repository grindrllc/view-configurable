//
// Copyright 2025 by Grindr LLC,
// All rights reserved.
//
// This software is confidential and proprietary information of
// Grindr LLC ("Confidential Information").
// You shall not disclose such Confidential Information and shall use
// it only in accordance with the terms of the license agreement
// you entered into with Grindr LLC.
//

import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ViewConfigurableMacro: ExtensionMacro {
    // swiftlint:disable line_length
    public static func expansion(of node: AttributeSyntax, attachedTo declaration: some DeclGroupSyntax, providingExtensionsOf type: some TypeSyntaxProtocol, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
        let scopeModifier = declaration.getScope().getCode()

        // Look for the `ViewConfiguration` struct
        guard let configStruct = declaration.memberBlock.members
            .compactMap({ $0.decl.as(StructDeclSyntax.self) })
            .first(where: { $0.name.text == "ViewConfiguration" }) else {
            let warning = GrindrMacrosWarning(
                .missingViewConfigurationStruct,
                message: "Your view must have a struct called ViewConfiguration",
                severity: .warning)
            let fixitMessage = MacroFixItMessage("Add struct")
            context.diagnose(
                Diagnostic(node: node, message: warning, fixIt: FixIt(message: fixitMessage, changes: [
                    .replaceTrailingTrivia(token: declaration.memberBlock.leftBrace, newTrivia: .newlines(2) +
                    """
                    private struct ViewConfiguration {
                        // TODO: Add configuration properties here
                    }
                    """ + .newline
                ),
                ]))
            )

            throw MacroError("Your view must have a struct called ViewConfiguration")
        }

        // swiftlint:disable unused_optional_binding
        // Look for a `private var config: ViewConfiguration`
        guard let _ = declaration.memberBlock.members
            .compactMap({
                $0.decl.as(VariableDeclSyntax.self)
            })
            .first(where: {
                $0.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == "viewConfig"
            }) else {

            let warning = GrindrMacrosWarning(.missingConfigVar,
                                              message: "Your view must have a struct called ViewConfiguration",
                                              severity: .warning)
            let fixitMessage = MacroFixItMessage("Add member")

            context.diagnose(
                Diagnostic(node: node, message: warning, fixIt: FixIt(message: fixitMessage, changes: [
                    .replaceTrailingTrivia(token: declaration.memberBlock.leftBrace, newTrivia: .newline +
                    """
                    private var viewConfig = ViewConfiguration()
                    """ + .newline
                ),
                ]))
            )
            throw MacroError("Make sure you have a `private var viewConfig = ViewConfiguration()` in your view")
        }

        // Now that we have the struct, and know that config exists, let's create a bunch of setter functions.
        // Each setter funciton will take the variable name & type and turn it into a function.
        // For example:
        /*
         struct ViewConfiguration {
            var textColor: Color
         }

         becomes 👇

         func textColor(_ newValue: Color) -> Self {
             var mutableSelf = self
             mutableSelf.viewConfig.textColor = newValue
             return mutableSelf
         }
         */
        let setterMethods = try configStruct.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .compactMap { (varDecl: VariableDeclSyntax) -> String? in
                guard let (varName, type) = try Self.getVarNameAndType(from: varDecl) else {
                    if let binding = varDecl.bindings.first {
                        throw MacroError("Unsupported: \(String(describing: binding.description))")
                    } else {
                        throw MacroError("Hit an issue with \(varDecl.description)")
                    }
                }

                return """
                func \(varName)(_ newValue: \(type)) -> Self {
                    var mutableSelf = self
                    mutableSelf.viewConfig.\(varName) = newValue
                    return mutableSelf
                }
                """
            }

        let setterMethodsStr = setterMethods.joined(separator: "\n")

        // Let's create the actual extensions. `extension ViewConfigurableProtocol` could probably get removed as it doesn't have explicit functionality atm.
        // However, it might be fun to work with this protocol to extend our functionality furter
        let syntax = try ExtensionDeclSyntax(
        """
        extension \(type): ViewConfigurableProtocol {}

        \(raw: scopeModifier)extension \(type) {

            \(raw: setterMethodsStr)

        }
        """
        )

        return [syntax]
    }
}

private extension ViewConfigurableMacro {
    static func getVarNameAndType(from varDecl: VariableDeclSyntax) throws -> (varName: String, type: String)? {
        guard let identifierPattern = varDecl.bindings.first?.pattern.as(IdentifierPatternSyntax.self) else {
            return nil
        }

        let varName = identifierPattern.identifier.text

        // IdentifierTypeSyntax is normal var syntax something like:
        // ex: var x: Int
        // ex2: var y: String
        if let type = varDecl.bindings.first?.typeAnnotation?.type.as(IdentifierTypeSyntax.self) {
            var name = type.description
            if name.last?.isWhitespace == true {
                name = String(name.dropLast())
            }
            return (varName, name)
        }

        // This is for optional var declarations, like:
        // ex: var x: Int?
        // ex2: var y: String?
        if let optionalType = varDecl.bindings.first?.typeAnnotation?.type.as(OptionalTypeSyntax.self),
           let wrappedType = optionalType.wrappedType.as(IdentifierTypeSyntax.self)?.name.text {
            return (varName, wrappedType + optionalType.questionMark.text)
        }

        // MemberTypeSyntax is a dot syntax, see example below:
        // ex: var size: GrindrIndicator.Size = .md
        if let memberType = varDecl.bindings.first?.typeAnnotation?.type.as(MemberTypeSyntax.self) {
            let type = memberType.description
            return (varName, type)
        }

        // This is for direct initialization. Think something like:
        // let size = CGSize(width: 12, height: 12)
        // Notice there is not an explicit "type" as there would be with:
        // let size: CGSize = .init(...)
        if let initType = varDecl.bindings.first?.initializer?.value.as(FunctionCallExprSyntax.self)?.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text {
            return (varName, initType)
        }

        // This is for direct initialization with a member. Think something like:
        // let animation = Animation.default
        // Notice there is not an explicit "type" as there would be with:
        // let size: CGSize = Animation.default
        if let initType = varDecl.bindings.first?.initializer?.value.as(MemberAccessExprSyntax.self)?.base?.as(DeclReferenceExprSyntax.self)?.baseName.text {
            return (varName, initType)
        }

        // This is for functions/callbacks, think something like:
        // var onScroll: () -> Void = {}
        if let funcType = varDecl.bindings.first?.typeAnnotation?.type.as(FunctionTypeSyntax.self) {
            return (varName, "@escaping " + funcType.description)
        }

        /*
         NOTE: If something is unexpectedly not showing up, it is likely not being caught in the above cases. This is to be expected (there are a LOT of ways to declare variables)

         To debug, paste the following `throw` line below this comment to understand the structure of your variable. Once you understand the structure, you can write a similar `if let` like we have above. If you are really stuck, ask in #ios-dev

         throw MacroError(varDecl.debugDescription)
         */

        return nil
    }
}
