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
struct ViewConfigurableMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ViewConfigurableMacro.self,
    ]
}
