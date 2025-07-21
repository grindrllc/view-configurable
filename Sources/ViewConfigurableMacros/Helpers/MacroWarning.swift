//
//  MacroWarning.swift
//  ViewConfigurable
//
//  Created by Max Roche on 7/17/25.
//

import SwiftDiagnostics

enum MacroWarningType: String {
    // ViewConfiguration
    case missingViewConfigurationStruct
    case missingConfigVar
}

struct MacroWarning: DiagnosticMessage {
    var message: String
    var diagnosticID: MessageID
    var severity: DiagnosticSeverity

    init(_ type: MacroWarningType, message: String, severity: DiagnosticSeverity = .warning) {
        self.message = message
        self.diagnosticID = .init(domain: "ViewConfigurableMacros", id: type.rawValue)
        self.severity = severity
    }

    init(_ type: MacroWarningType, error: MacroError, severity: DiagnosticSeverity) {
        self.message = error.localizedDescription
        self.diagnosticID = .init(domain: "ViewConfigurableMacros", id: type.rawValue)
        self.severity = severity
    }
}
