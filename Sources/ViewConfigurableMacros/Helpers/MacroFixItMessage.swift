//
//  MacroFixItMessage.swift
//  ViewConfigurable
//
//  Created by Max Roche on 7/17/25.
//

import SwiftDiagnostics

struct MacroFixItMessage: FixItMessage {
    let message: String
    let fixItID: MessageID

    init(_ message: String) {
        self.message = message
        self.fixItID = MessageID(domain: "ViewConfigurable", id: "fixit.\(message)")
    }
}
