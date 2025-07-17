//
//  MacroScopeType.swift
//  ViewConfigurable
//
//  Created by Max Roche on 7/17/25.
//

import Foundation
//import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum ScopeType: String {
    case privateScope = "private"
    case filePrivateScope = "fileprivate"
    case internalScope = "internal"
    case publicScope = "public"
    case openScope = "open"

    func getCode(addsTrailingSpaceIfNeeded: Bool = true) -> String {
        switch self {
        case .internalScope:
            return ""
        default:
            if addsTrailingSpaceIfNeeded {
                return rawValue + " "
            } else {
                return rawValue
            }
        }
    }
}

extension DeclGroupSyntax {
    func getScope() -> ScopeType {
        return modifiers.map(\.name.text)
            .compactMap(ScopeType.init)
            .first ?? .internalScope
    }
}
