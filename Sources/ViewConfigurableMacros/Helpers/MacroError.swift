//
//  MacroError.swift
//  ViewConfigurable
//
//  Created by Max Roche on 7/17/25.
//

import Foundation

struct MacroError: CustomStringConvertible, Error {
    let message: String

    init(_ message: String) {
        self.message = "VC Macro Error: \(message)"
    }

    var description: String {
        message
    }
}
