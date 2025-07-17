//
//  Plugins.swift
//  ViewConfigurable
//
//  Created by Max Roche on 7/17/25.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct GrindrMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ViewConfigurableMacro.self,
    ]
}
